
//  VehicleManager.swift
//  openXCSwift
//  Created by Tim Buick on 2016-06-16.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//  Vrsion 0.9.2
import Foundation
import CoreBluetooth
import SwiftProtobuf


// comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

// public enum VehicleManagerStatusMessage
// values reported to managerCallback if defined
public enum VehicleManagerStatusMessage: Int {
  case c5DETECTED=1               // C5 VI was detected
  case c5CONNECTED=2              // C5 VI connection established
  case c5SERVICEFOUND=3           // C5 VI OpenXC service detected
  case c5NOTIFYON=4               // C5 VI notification enabled
  case c5DISCONNECTED=5           // C5 VI disconnected
  case trace_SOURCE_END=6         // configured trace input end of file reached
  case trace_SINK_WRITE_ERROR=7   // error in writing message to trace file
  case ble_RX_DATA_PARSE_ERROR=8  // error in parsing data received from VI
  case networkDISCONNECTED=9      // Network Data Source disconnected
  case networkCONNECTED=10        // Network Data Source connected
}
// This enum is outside of the main class for ease of use in the client app. It allows
// for referencing the enum without the class hierarchy in front of it. Ie. the enums
// can be accessed directly as .C5DETECTED for example
// public enum VehicleManagerConnectionState
// values reported in public variable connectionState
open class VehicleManager: NSObject {
  // MARK: Singleton Init
  // This signleton init allows mutiple controllers to access the same instantiation
  // of the VehicleManager. There is only a single instantiation of the VehicleManager
  // for the entire client app
  static public let sharedInstance: VehicleManager = {
    let instance = VehicleManager()
    return instance
  }()


  // config for outputting debug messages to console
    fileprivate var managerDebug : Bool = false
    
  // config for protobuf vs json BLE mode, defaults to JSON
  public var jsonMode : Bool = true
  // optional variable holding callback for VehicleManager status updates
   var managerCallBack: TargetAction?
  
  // data buffer for receiving raw BTLE data
  public var RxDataBuffer: NSMutableData! = NSMutableData()
  public var tempDataBuffer: NSMutableData! = NSMutableData()
  
  // data buffer for storing vehicle messages to send to BTLE
  //Ranjan changed fileprivate to public due to travis fail
  public var bleTransmitDataBuffer: NSMutableArray! = NSMutableArray()

  // BTLE transmit semaphore variable
  fileprivate var bleTransmitWriteCount: Int = 0
  // BTLE transmit token increment variable
  fileprivate var bleTransmitSendToken: Int = 0
  fileprivate var multiFramePayload : String = ""
  
  // ordered list for storing callbacks for in progress vehicle commands
  fileprivate var bleTransmitCommandCallBack = [TargetAction]()
  // mirrored ordered list for storing command token for in progress vehicle commands
  fileprivate var bleTransmitCommandToken = [String]()
  // 'default' command callback. If this is defined, it takes priority over any other callback
  // defined above
  fileprivate var defaultCommandCallBack : TargetAction?
  
  
  // dictionary for holding registered measurement message callbacks
  // pairing measurement String with callback action
  fileprivate var measurementCallBacks = [NSString:TargetAction]()
  // default callback action for measurement messages not registered above
  fileprivate var defaultMeasurementCallBack : TargetAction?
  // dictionary holding last received measurement message for each measurement type
  fileprivate var latestVehicleMeasurements = [NSString:VehicleMeasurementResponse]()
  
  // dictionary for holding registered diagnostic message callbacks
  // pairing bus-id-mode(-pid) String with callback action
  fileprivate var diagCallBacks = [NSString:TargetAction]()
  // default callback action for diagnostic messages not registered above
  fileprivate var defaultDiagCallBack : TargetAction?
  
  // dictionary for holding registered diagnostic message callbacks
  // pairing bus-id String with callback action
  fileprivate var canCallBacks = [NSString:TargetAction]()
  // default callback action for can messages not registered above
  fileprivate var defaultCanCallBack : TargetAction?
  
  public var throughputEnabled: Bool = false
  // config variable determining whether trace output is generated
  fileprivate var msg : Openxc_VehicleMessage!
  //Connected to network simulator
  open var isNetworkConnected: Bool = false

 //Iphone device blutooth is on/fff status
  open var isDeviceBluetoothIsOn :Bool = false
  var callbackHandler: ((Bool) -> ())?  = nil
    //Connected to Ble simulator
   // open var isBleConnected: Bool = false
    //Connected to tracefile simulator
    open var isTraceFileConnected: Bool = false

  // diag last req msg id
  open var lastReqMsg_id : NSInteger = 0
  // MARK: Class Functions
  
  // set the callback for VM status updates
  open func setManagerCallbackTarget<T: AnyObject>(_ target: T, action: @escaping (T) -> (NSDictionary) -> ()) {
    managerCallBack = TargetActionWrapper(key:"", target: target, action: action)
  }
  
  // change the debug config for the VM
  open func setManagerDebug(_ on:Bool) {
    managerDebug = on
  }
  
  // private debug log function gated by the debug setting
  fileprivate func vmlog(_ strings:Any...){
    if managerDebug {
      let d = Date()
      let df = DateFormatter()
      df.dateFormat = "[H:m:ss.SSS]"
      print(df.string(from: d),terminator:"")
      print(" ",terminator:"")
      for string in strings {
        print(string,terminator:"")
      }
      print("")
    }
  }
  // change the data format for the VM
  open func setProtobufMode(_ on:Bool) {

    if on{
    jsonMode = false
    }
    else{
    jsonMode = true
    }
  }
  // change the throughput for the VM
  open func setThroughput(_ on:Bool) {
    
    if on{
      throughputEnabled = true
    }
    else{
      throughputEnabled = false
    }
  }
  open func getLatest(_ key:NSString) -> VehicleMeasurementResponse? {
    return latestVehicleMeasurements[key]
  }
  
  // add a callback for a given measurement string name
  open func addMeasurementTarget<T: AnyObject>(_ key: NSString, target: T, action: @escaping (T) -> (NSDictionary) -> ()) {
    measurementCallBacks[key] = TargetActionWrapper(key:key, target: target, action: action)
  }
  
  // clear the callback for a given measurement string name
  open func clearMeasurementTarget(_ key: NSString) {
    measurementCallBacks.removeValue(forKey: key)
  }
  
  // add a default callback for any measurement messages not include in specified callbacks
  open func setMeasurementDefaultTarget<T: AnyObject>(_ target: T, action: @escaping (T) -> (NSDictionary) -> ()) {
    defaultMeasurementCallBack = TargetActionWrapper(key:"", target: target, action: action)
  }
  
  // clear default callback (by setting the default callback to a null method)
  open func clearMeasurementDefaultTarget() {
    defaultMeasurementCallBack = TargetActionWrapper(key: "", target: VehicleManager.sharedInstance, action: VehicleManager.CallbackNull)
  }

  // send a command message with a callback for when the command response is received
  open func sendCommand<T: AnyObject>(_ cmd:VehicleCommandRequest, target: T, action: @escaping (T) -> (NSDictionary) -> ()) -> String {
    vmlog("in sendCommand:target")
    
    // if we have a trace input file, ignore this request!
    if (TraceFileManager.sharedInstance.traceFileSourceEnabled) {
        return ""
        
    }
    
    // save the callback in order, so we know which to call when responses are received
    bleTransmitSendToken += 1
    let key : String = String(bleTransmitSendToken)
    let act : TargetAction = TargetActionWrapper(key:key as NSString, target: target, action: action)
    bleTransmitCommandCallBack.append(act)
    bleTransmitCommandToken.append(key)
    
    // common command send method
    sendCommandCommon(cmd)
    
    return key
    
  }
  
  // send a command message with no callback specified
  open func sendCommand(_ cmd:VehicleCommandRequest) {
    vmlog("in sendCommand")
    
    // if we have a trace input file, ignore this request!
    if (TraceFileManager.sharedInstance.traceFileSourceEnabled) {
        return
        
    }
    
    // we still need to keep a spot for the callback in the ordered list, so
    // nothing gets out of sync. Assign the callback to the null callback method.
    bleTransmitSendToken += 1
    let key : String = String(bleTransmitSendToken)
    let act : TargetAction = TargetActionWrapper(key: "", target: VehicleManager.sharedInstance, action: VehicleManager.CallbackNull)
    bleTransmitCommandCallBack.append(act)
    bleTransmitCommandToken.append(key)
    
    // common command send method
    sendCommandCommon(cmd)
    
  }
  
  
  // add a default callback for any measurement messages not include in specified callbacks
  open func setCommandDefaultTarget<T: AnyObject>(_ target: T, action: @escaping (T) -> (NSDictionary) -> ()) {
    defaultCommandCallBack = TargetActionWrapper(key:"", target: target, action: action)
  }
  
  // clear default callback (by setting the default callback to a null method)
  open func clearCommandDefaultTarget() {
    defaultCommandCallBack = nil
  }

  // send a diagnostic message with a callback for when the diag command response is received
  open func sendDiagReq<T: AnyObject>(_ cmd:VehicleDiagnosticRequest, target: T, cmdaction: @escaping (T) -> (NSDictionary) -> ()) -> String {
    vmlog("in sendDiagReq:cmd")
    
    // if we have a trace input file, ignore this request!
    if (TraceFileManager.sharedInstance.traceFileSourceEnabled) {
        return ""
        
    }
    
    // save the callback in order, so we know which to call when responses are received
    bleTransmitSendToken += 1
    let key : String = String(bleTransmitSendToken)
    let act : TargetAction = TargetActionWrapper(key:key as NSString, target: target, action: cmdaction)
    bleTransmitCommandCallBack.append(act)
    bleTransmitCommandToken.append(key)
    
    // common diag send method
    sendDiagCommon(cmd)
    
    return key
    
  }
  
  // send a diagnostic message with no callback specified
  open func sendDiagReq(_ cmd:VehicleDiagnosticRequest) {
    vmlog("in sendDiagReq")
    
    // if we have a trace input file, ignore this request!
    if (TraceFileManager.sharedInstance.traceFileSourceEnabled) {
        return
        
    }
    
    // we still need to keep a spot for the callback in the ordered list, so
    // nothing gets out of sync. Assign the callback to the null callback method.
    bleTransmitSendToken += 1
    let key : String = String(bleTransmitSendToken)
    let act : TargetAction = TargetActionWrapper(key: "", target: VehicleManager.sharedInstance, action: VehicleManager.CallbackNull)
    bleTransmitCommandCallBack.append(act)
    bleTransmitCommandToken.append(key)
    
    // common diag send method
    vmlog("diag cmd..", cmd)
    sendDiagCommon(cmd)
    
  }
  
  
  // set a callback for any diagnostic messages received with a given set of keys.
  // The key is bus-id-mode-pid if there are 4 keys specified in the parameter.
  // The key becomes bus-id-mode-X if there are 3 keys specified, indicating that pid does not exist
  open func addDiagnosticTarget<T: AnyObject>(_ keys: [NSInteger], target: T, action: @escaping (T) -> (NSDictionary) -> ()) {
    let key : NSMutableString = ""
    var first : Bool = true
    for i in keys {
      if !first {
        key.append("-")
      }
      first=false
      key.append(String(i))
    }
    if keys.count == 3 {
      key.append("-X")
    }
    // key string has been created
    vmlog("add diag key=",key)
    // save the callback associated with the key
    diagCallBacks[key] = TargetActionWrapper(key:key, target: target, action: action)
  }
  
  // clear a callback for a given set of keys, defined as above.
  open func clearDiagnosticTarget(_ keys: [NSInteger]) {
    let key : NSMutableString = ""
    var first : Bool = true
    for i in keys {
      if !first {
        key.append("-")
      }
      first=false
      key.append(String(i))
    }
    if keys.count == 3 {
      key.append("-X")
    }
    // key string has been created
    vmlog("rm diag key=",key)
    // clear the callback associated with the key
    diagCallBacks.removeValue(forKey: key)
  }
  
  // set a default callback for any diagnostic messages with a key set not specified above
  open func setDiagnosticDefaultTarget<T: AnyObject>(_ target: T, action: @escaping (T) -> (NSDictionary) -> ()) {
    defaultDiagCallBack = TargetActionWrapper(key:"", target: target, action: action)
  }
  
  // clear the default diag callback
  open func clearDiagnosticDefaultTarget() {
    defaultDiagCallBack = TargetActionWrapper(key: "", target: VehicleManager.sharedInstance, action: VehicleManager.CallbackNull)
  }
  

  // set a callback for any can messages received with a given set of keys.
  // The key is bus-id and 2 keys must be specified always
  open func addCanTarget<T: AnyObject>(_ keys: [NSInteger], target: T, action: @escaping (T) -> (NSDictionary) -> ()) {
    let key : NSMutableString = ""
    var first : Bool = true
    for i in keys {
      if !first {
        key.append("-")
      }
      first=false
      key.append(String(i))
    }
    // key string has been created
    vmlog("add can key=",key)
    // save the callback associated with the key
    diagCallBacks[key] = TargetActionWrapper(key:key, target: target, action: action)
  }
  
  // clear a callback for a given set of keys, defined as above.
  open func clearCanTarget(_ keys: [NSInteger]) {
    let key : NSMutableString = ""
    var first : Bool = true
    for i in keys {
      if !first {
        key.append("-")
      }
      first=false
      key.append(String(i))
    }
    // key string has been created
    vmlog("rm can key=",key)
    // clear the callback associated with the key
    diagCallBacks.removeValue(forKey: key)
  }
  
  
  // set a default callback for any can messages with a key set not specified above
  open func setCanDefaultTarget<T: AnyObject>(_ target: T, action: @escaping (T) -> (NSDictionary) -> ()) {
    defaultCanCallBack = TargetActionWrapper(key:"", target: target, action: action)
  }
  
  // clear the can diag callback
  open func clearCanDefaultTarget() {
    defaultCanCallBack = TargetActionWrapper(key: "", target: VehicleManager.sharedInstance, action: VehicleManager.CallbackNull)
  }
  
  
  
  // send a can message
  open func sendCanReq(_ cmd:VehicleCanRequest) {
    vmlog("in sendCanReq")
    
    // if we have a trace input file, ignore this request!
    if (TraceFileManager.sharedInstance.traceFileSourceEnabled) {
        return
        
    }
    
    // common can send method
    sendCanCommon(cmd)
    
  }

  
  ////////////////
  // private functions
  
  
  // common function for sending a VehicleCommandRequest
  fileprivate func sendCommandCommon(_ cmd:VehicleCommandRequest) {
    vmlog("in sendCommandCommon")
    
    if !jsonMode {
      // in protobuf mode, build the command message
      /*  let cbuild = Openxc.ControlCommand.Builder()
        self.protobufCommandRequest(cmd)
      
      if cmd.command == .predefined_odb2 {
        let cbuild2 = Openxc.PredefinedObd2RequestsCommand.Builder()
        _ = cbuild2.setEnabled(cmd.enabled)
        _ = cbuild.setPredefinedObd2RequestsCommand(cbuild2.buildPartial())
        _ = cbuild.setType(.predefinedObd2Requests)
      }
      if cmd.command == .modem_configuration {
        _ = cbuild.setType(.modemConfiguration)
        let cbuild2 = Openxc.ModemConfigurationCommand.Builder()
        let srv = Openxc.ServerConnectSettings.Builder()
        _ = srv.setHost(cmd.server_host as String)
        _ = srv.setPort(UInt32(cmd.server_port))
        _ = cbuild2.setServerConnectSettings(srv.buildPartial())
        _ = cbuild.setModemConfigurationCommand(cbuild2.buildPartial())
      }
      if cmd.command == .rtc_configuration {
        let cbuild2 = Openxc.RtcconfigurationCommand.Builder()
        _ = cbuild2.setUnixTime(UInt32(cmd.unix_time))
        _ = cbuild.setRtcConfigurationCommand(cbuild2.buildPartial())
        _ = cbuild.setType(.rtcConfiguration)
      }
      if cmd.command == .sd_mount_status {
        _ = cbuild.setType(.sdMountStatus)
        
        }
      
        let mbuild = Openxc.VehicleMessage.Builder()
      _ = mbuild.setType(.controlCommand)
      
      do {
        let cmsg = try cbuild.build()
        _ = mbuild.setControlCommand(cmsg)
        let mmsg = try mbuild.build()
        
        let cdata = mmsg.data()
        let cdata2 = NSMutableData()
        let prepend : [UInt8] = [UInt8(cdata.count)]
        cdata2.append(Data(bytes: UnsafePointer<UInt8>(prepend), count:1))
        cdata2.append(cdata)
        //print(cdata2)
        
        // append to tx buffer
        bleTransmitDataBuffer.add(cdata2)
        
        // trigger a BLE data send
        BluetoothManager.sharedInstance.bleSendFunction()

      } catch {
        print("command message failed")
        
      }
      
      return*/
    }
    
    // we're in json mode
    self.jsonCommandRequest(cmd)
    
   
    
  }
    /*
    fileprivate func protobufCommandRequest(_ cmd:VehicleCommandRequest){
        let cbuild = Openxc.ControlCommand.Builder()
         if cmd.command == .version {
           _ = cbuild.setType(.version)
           
           }
         if cmd.command == .device_id {
           _ = cbuild.setType(.deviceId)
           
           }
         if cmd.command == .platform {
           _ = cbuild.setType(.platform)
           
           }
         if cmd.command == .passthrough {
            let cbuild2 = Openxc.PassthroughModeControlCommand.Builder()
           _ = cbuild2.setBus(Int32(cmd.bus))
           _ = cbuild2.setEnabled(cmd.enabled)
           _ = cbuild.setPassthroughModeRequest(cbuild2.buildPartial())
           _ = cbuild.setType(.passthrough)
         }
         if cmd.command == .af_bypass {
            let cbuild2 = Openxc.AcceptanceFilterBypassCommand.Builder()
           _ = cbuild2.setBus(Int32(cmd.bus))
           _ = cbuild2.setBypass(cmd.bypass)
           _ = cbuild.setAcceptanceFilterBypassCommand(cbuild2.buildPartial())
           _ = cbuild.setType(.acceptanceFilterBypass)
         }
        if cmd.command == .payload_format {
            let cbuild2 = Openxc.PayloadFormatCommand.Builder()
          if cmd.format == "json" {
              _ = cbuild2.setFormat(.json)
              
          }
          if cmd.format == "protobuf" {
              _ = cbuild2.setFormat(.protobuf)
              
          }
          _ = cbuild.setPayloadFormatCommand(cbuild2.buildPartial())
          _ = cbuild.setType(.payloadFormat)
        }
        
        let mbuild = Openxc.VehicleMessage.Builder()
            _ = mbuild.setType(.controlCommand)
        do {
          let cmsg = try cbuild.build()
          _ = mbuild.setControlCommand(cmsg)
          let mmsg = try mbuild.build()
          //print (mmsg)
          
          
          let cdata = mmsg.data()
          let cdata2 = NSMutableData()
          let prepend : [UInt8] = [UInt8(cdata.count)]
          cdata2.append(Data(bytes: UnsafePointer<UInt8>(prepend), count:1))
          cdata2.append(cdata)
          //print(cdata2)
          
          // append to tx buffer
          bleTransmitDataBuffer.add(cdata2)
          
          // trigger a BLE data send
          BluetoothManager.sharedInstance.bleSendFunction()

        } catch {
          print("command message failed")
          
        }
    }*/
    
    fileprivate func jsonCommandRequest(_ cmd:VehicleCommandRequest){
        var cmdstr = ""
        // decode the command type and build the command depending on the command

        if cmd.command == .version || cmd.command == .device_id || cmd.command == .sd_mount_status || cmd.command == .platform {
          // build the command json
          cmdstr = "{\"command\":\"\(cmd.command.rawValue)\"}\0"
        }
        else if cmd.command == .passthrough {
          // build the command json
          cmdstr = "{\"command\":\"\(cmd.command.rawValue)\",\"bus\":\(cmd.bus),\"enabled\":\(cmd.enabled)}\0"
        }
        else if cmd.command == .af_bypass {
          // build the command json
          cmdstr = "{\"command\":\"\(cmd.command.rawValue)\",\"bus\":\(cmd.bus),\"bypass\":\(cmd.bypass)}\0"
        }
        else if cmd.command == .payload_format {
          // build the command json
          cmdstr = "{\"command\":\"\(cmd.command.rawValue)\",\"format\":\"\(cmd.format)\"}\0"
        }
        else if cmd.command == .predefined_odb2 {
          // build the command json
          cmdstr = "{\"command\":\"\(cmd.command.rawValue)\",\"enabled\":\(cmd.enabled)}\0"
        }
        else if cmd.command == .modem_configuration {
          // build the command json
          cmdstr = "{\"command\":\"\(cmd.command.rawValue)\",\"server\":{\"host\":\"\(cmd.server_host)\",\"port\":\(cmd.server_port)}}\0"
        }
        else if cmd.command == .rtc_configuration {
          // build the command json
          let timeInterval = Date().timeIntervalSince1970
          cmd.unix_time = NSInteger(timeInterval);
          print("timestamp is..",cmd.unix_time)
          cmdstr = "{\"command\":\"\(cmd.command.rawValue)\",\"unix_time\":\"\(cmd.unix_time)\"}\0"
        } else {
          // unknown command!
          return
          
        }
        // append to tx buffer
           bleTransmitDataBuffer.add(cmdstr.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
           
           // trigger a BLE data send
           BluetoothManager.sharedInstance.bleSendFunction()
    }
    
  
  // common function for sending a VehicleDiagnosticRequest
  fileprivate func sendDiagCommon(_ cmd:VehicleDiagnosticRequest) {
    vmlog("in sendDiagCommon")
    
    if !jsonMode {
      // in protobuf mode, build diag message
       /* let cbuild = Openxc.ControlCommand.Builder()
      _ = cbuild.setType(.diagnostic)
        let c2build = Openxc.DiagnosticControlCommand.Builder()
      _ = c2build.setAction(.add)
        let dbuild = Openxc.DiagnosticRequest.Builder()
      _ = dbuild.setBus(Int32(cmd.bus))
      _ = dbuild.setMessageId(UInt32(cmd.message_id))
      _ = dbuild.setMode(UInt32(cmd.mode))
      if cmd.pid != nil {
        _ = dbuild.setPid(UInt32(cmd.pid!))
      }
      if cmd.frequency>0 {
        _ =  dbuild.setFrequency(Double(cmd.frequency))
      }
        let mbuild = Openxc.VehicleMessage.Builder()
      _ = mbuild.setType(.controlCommand)
      
      do {
        let dmsg = try dbuild.build()
        _ = c2build.setRequest(dmsg)
        let c2msg = try c2build.build()
        _ = cbuild.setDiagnosticRequest(c2msg)
        let cmsg = try cbuild.build()
        _ = mbuild.setControlCommand(cmsg)
        let mmsg = try mbuild.build()
        //print (mmsg)
        
        
        let cdata = mmsg.data()
        let cdata2 = NSMutableData()
        let prepend : [UInt8] = [UInt8(cdata.count)]
        cdata2.append(Data(bytes: UnsafePointer<UInt8>(prepend), count:1))
        cdata2.append(cdata)
        print("DiagnosticRequest>>\(cdata2)")
        
        // append to tx buffer
        bleTransmitDataBuffer.add(cdata2)
        
        // trigger a BLE data send
        BluetoothManager.sharedInstance.bleSendFunction()
        
      } catch {
        print("command build failed")
      }
      
      return*/
    }
    self.lastReqMsg_id = cmd.message_id

    // build the command json
    let cmdjson : NSMutableString = ""
    cmdjson.append("{\"command\":\"diagnostic_request\",\"action\":\"add\",\"request\":{\"bus\":\(cmd.bus),\"id\":\(cmd.message_id),\"mode\":\(cmd.mode)")
    
    if cmd.pid != nil {
      cmdjson.append(",\"pid\":\(cmd.pid!)")
    }
    if cmd.frequency > 0 {
      cmdjson.append(",\"frequency\":\(cmd.frequency)")
    }
    
    
    
    if !cmd.payload.isEqual(to: "") {
      
      let payloadStr = String(cmd.payload)
      cmdjson.append(",\"payload\":")
      
      let char = "\""
      
      cmdjson.append(char)
      cmdjson.append(payloadStr)
      cmdjson.append(char)
    }
    
    cmdjson.append("}}\0")
    
    vmlog("sending diag cmd:",cmdjson)
    // append to tx buffer
    bleTransmitDataBuffer.add(cmdjson.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!)
    
    // trigger a BLE data send
    BluetoothManager.sharedInstance.bleSendFunction()
    
  }
  
  
  // common function for sending a VehicleCanRequest
  fileprivate func sendCanCommon(_ cmd:VehicleCanRequest) {
    vmlog("in sendCanCommon")
    
    
    
    if !jsonMode {
      // in protobuf mode, build the CAN message
       /* let cbuild = Openxc.CanMessage.Builder()
      _ = cbuild.setBus(Int32(cmd.bus))
      _ = cbuild.setId(UInt32(cmd.id))
      let data = NSMutableData()
      var str : NSString = cmd.data
      while str.length>0 {
        let substr = str.substring(to: 1)
        var num = UInt8(substr, radix: 16)
        data.append(&num, length:1)
        str = str.substring(from: 2) as NSString
      }
      _ = cbuild.setData(data as Data)
      
        let mbuild = Openxc.VehicleMessage.Builder()
      _ = mbuild.setType(.can)
      
      do {
        let cmsg = try cbuild.build()
        _ = mbuild.setCanMessage(cmsg)
        let mmsg = try mbuild.build()
        //print (mmsg)
        
        
        let cdata = mmsg.data()
        let cdata2 = NSMutableData()
        let prepend : [UInt8] = [UInt8(cdata.count)]
        cdata2.append(Data(bytes: UnsafePointer<UInt8>(prepend), count:1))
        cdata2.append(cdata)
        //print(cdata2)
        
        // append to tx buffer
        bleTransmitDataBuffer.add(cdata2)
        
        // trigger a BLE data send
        BluetoothManager.sharedInstance.bleSendFunction()
        
      } catch {
        print("cmd msg build failed")
      }
      
      return*/
    }
    
    
    
    
    // build the command json
    let cmdjson : NSMutableString = ""
    cmdjson.append("{\"bus\":\(cmd.bus),\"id\":\(cmd.id),\"data\":\"\(cmd.data)\"}\0")
    // append to tx buffer
    bleTransmitDataBuffer.add(cmdjson.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)!)
    
    // trigger a BLE data send
    BluetoothManager.sharedInstance.bleSendFunction()
    
  }
  
  
  // internal method used when a callback needs to be registered, but we don't
  // want it to actually do anything, for example a command request where we don't
  // want a callback for the command response. The command response is still received
  // but the callback registered comes here, and does nothing.
  //Ranjan changed fileprivate to public due to travis build fail
  public func CallbackNull(_ o:AnyObject) {
    vmlog("in CallbackNull")
  }
  

  
  //Methods For parssing diffrent messages ................
  
  ////////////////
  // Protobuf decoding
  /////////////////
  
  
  fileprivate func protobufDecoding(data_chunk:NSMutableData,packetlen:Int){
    
    
    
    do {
        
        msg = try Openxc_VehicleMessage(serializedData: data_chunk as Data )
        print("Decoding  Message>>>>\(msg)")
    
       // msg = try Openxc_SimpleMessage(serializedData: data_chunk as Data)
      
      let data_left : NSMutableData = NSMutableData()
      data_left.append(RxDataBuffer.subdata(with: NSMakeRange(packetlen+1, RxDataBuffer.length-packetlen-1)))
      RxDataBuffer = data_left
    
      var decoded = false
      
      // measurement messages (normal and evented)
      ///////////////////////////////////////////
      if msg.type == .simple {
        
        decoded = true
        self.protobufMeasurementMessage(msg : msg)
      }
      
      // Command Response messages
      /////////////////////////////
      if msg.type == .commandResponse {
        let nameValue = msg.commandResponse.type
        if nameValue != .diagnostic{
          decoded = true
            print("Response command>>>>\(msg)")
          //self.protobufCommandResponse(msg : msg)
        }
        
      }
      
      // Diagnostic messages
      /////////////////////////////
      if msg.type == .diagnostic {
        decoded = true
        print("Response Diagnostic>>>>\(msg)")
       // self.protobufDignosticMessage(msg: msg)
      }
      
      // CAN messages
      /////////////////////////////
      if msg.type == .can {
        decoded = true
        //self.protobufCanMessage(msg: msg)
        
      }
      
      if (!decoded) , let act = managerCallBack {
        // should never get here!
          act.performAction(["status":VehicleManagerStatusMessage.ble_RX_DATA_PARSE_ERROR.rawValue] as NSMutableDictionary)
        
      }
    } catch {
      //self.jsonMode = true
      print("protobuf parse error")
      return
    }

  }
  
    fileprivate func protobufMeasurementMessage(msg : Openxc_VehicleMessage){
    //let name = msg.simpleMessage.name
    let name = msg.simpleMessage.name as NSString
        let resultString = String(describing: msg)
       // let vr = Dictionary(resultString)
        print("Converting to string\(resultString)")
    // build measurement message
        //let vr = msg.simpleMessage as!  NSString
         //print("Response >>>\(vr)")
       
    let rsp : VehicleMeasurementResponse = VehicleMeasurementResponse()
//        if let timestamp = msg.timestamp{
//            rsp.timeStamp = Int(truncatingIfNeeded:timestamp)
//        }
    rsp.timeStamp = Int(truncatingIfNeeded:msg.timestamp)
    //rsp.name = msg.simpleMessage.name as NSString
    
    rsp.name = name
       
    self.protobufMeasurement(rsp: rsp,name: name, msg: msg)
    
  }
    
    
    fileprivate func protobufMeasurement(rsp : VehicleMeasurementResponse, name:NSString,msg : Openxc_VehicleMessage){
       
        if msg.hasSimpleMessage{
            rsp.value = msg.simpleMessage.value.stringValue as AnyObject
            rsp.value = msg.simpleMessage.value.booleanValue as AnyObject
            rsp.value = msg.simpleMessage.value.numericValue as AnyObject
            if msg.simpleMessage.hasEvent {
              rsp.isEvented = true
              
                rsp.event = msg.simpleMessage.event.stringValue as AnyObject
             
                rsp.event = msg.simpleMessage.event.booleanValue as AnyObject
              
                rsp.event = msg.simpleMessage.event.numericValue as AnyObject
            }
        }
        /*if msg.simpleMessage.value.stringValue.hasStringValue {
          rsp.value = msg.simpleMessage.value.stringValue as AnyObject}
      if msg.simpleMessage.value.hasBooleanValue {
          rsp.value = msg.simpleMessage.value.booleanValue as AnyObject}
      if msg.simpleMessage.value.hasNumericValue {
          rsp.value = msg.simpleMessage.value.numericValue as AnyObject}
      if msg.simpleMessage.hasEvent {
        rsp.isEvented = true
        if msg.simpleMessage.event.hasStringValue {
          rsp.event = msg.simpleMessage.event.stringValue as AnyObject}
        if msg.simpleMessage.event.hasBooleanValue {
          rsp.event = msg.simpleMessage.event.booleanValue as AnyObject}
        if msg.simpleMessage.event.hasNumericValue {
          rsp.event = msg.simpleMessage.event.numericValue as AnyObject}
      }*/
        self.protoSimpleMsgCheck(rsp:rsp,name:name)

  }
    
    fileprivate func protoSimpleMsgCheck(rsp : VehicleMeasurementResponse, name:NSString){
        
        // capture this message into the dictionary of latest messages
        latestVehicleMeasurements[name] = rsp
        
        // look for a specific callback for this measurement name
        var found=false
        print(measurementCallBacks.keys)
        for key in measurementCallBacks.keys {
          let act = measurementCallBacks[key]
          if act!.returnKey() == name {
            found=true
            act!.performAction(["vehiclemessage":rsp] as NSDictionary)
          }
        }
        // otherwise use the default callback if it exists
        if !found , let act = defaultMeasurementCallBack {
          
            act.performAction(["vehiclemessage":rsp] as NSDictionary)
        
        }
    }
  
   /* fileprivate func protobufCommandResponse(msg : Openxc.VehicleMessage){

    let name = msg.commandResponse.type.description
    // build command response message
    print(msg)
    let rsp : VehicleCommandResponse = VehicleCommandResponse()
        if let timestamp = msg.timestamp{
                 rsp.timeStamp = Int(truncatingIfNeeded:timestamp)
             }
        //rsp.timeStamp = Int(truncatingIfNeeded:msg.timestamp)
        rsp.command_response = name.lowercased() as NSString
        rsp.message = msg.commandResponse.message as NSString
        rsp.status = msg.commandResponse.status

    // First see if the default command callback is defined. If it is
    // then that takes priority. This will be the most likely use case,
    // with a single command response handler.
    if let act = defaultCommandCallBack {
      act.performAction(["vehiclemessage":rsp] as NSDictionary)
    }
      // Otherwise, grab the first callback message in the list of command callbacks.
      // They will be in order relative to when the commands are sent (VI guarantees
      // to response order). We need to check that the list of command callbacks
      // actually has something in it here (check for count>0) because if we're
      // receiving command responses via a trace file, then there was never an
      // actual command request message sent to the VI.
    else if bleTransmitCommandCallBack.count > 0 {
      let ta : TargetAction = bleTransmitCommandCallBack.removeFirst()
      let s : String = bleTransmitCommandToken.removeFirst()
      ta.performAction(["vehiclemessage":rsp,"key":s] as NSDictionary)
    }
  }*/
    
  
/*fileprivate func protobufDignosticMessage(msg : Openxc.VehicleMessage){

    // build diag response message
    let rsp : VehicleDiagnosticResponse = VehicleDiagnosticResponse()
        if let timestamp = msg.timestamp{
                 rsp.timeStamp = Int(truncatingIfNeeded:timestamp)
             }
    //rsp.timeStamp = Int(truncatingIfNeeded:msg.timestamp)
//        if (frame != -1){
//        if let payloadX = json["payload"] as? String,frame == 0   {
//                multiFramePayload = payloadX
//                print("payload : \(multiFramePayload)")
//            return
//                }
//        }else{
    rsp.bus = Int(msg.diagnosticResponse.bus)
    rsp.message_id = Int(msg.diagnosticResponse.messageId)
    rsp.mode = Int(msg.diagnosticResponse.mode)
    if msg.diagnosticResponse.hasPid {
        rsp.pid = Int(msg.diagnosticResponse.pid)
    }
    if  let successValue =  msg.diagnosticResponse.success {
        rsp.success = successValue //msg.diagnosticResponse.success
    }
    if msg.diagnosticResponse.hasValue {
        rsp.value = msg.diagnosticResponse.value as! NSInteger
        print(msg.diagnosticResponse.value as Any)
        
    }
    
    if rsp.value != 0 {
       rsp.success = true//msg.diagnosticResponse.success
    }
    // build the key that identifies this diagnostic response
    // bus-id-mode-[X or pid]
    let tupple : NSMutableString = ""
    tupple.append("\(String(rsp.bus))-\(String(rsp.message_id))-\(String(rsp.mode))-")
    if rsp.pid != 0 {
      tupple.append(String(describing: rsp.pid))
    } else {
      tupple.append("X")
    }
    
    // TODO: debug printouts, maybe remove
    if rsp.value != 0 {
      if rsp.pid != 0 {
        vmlog("diag rsp msg:\(rsp.bus) id:\(rsp.message_id) mode:\(rsp.mode) pid:\(rsp.pid ) success:\(rsp.success) value:\(rsp.value )")
      } else {
        vmlog("diag rsp msg:\(rsp.bus) id:\(rsp.message_id) mode:\(rsp.mode) success:\(rsp.success) value:\(rsp.value )")
      }
    }
    ////////////////////////////
    
    // look for a specific callback for this diag response based on tupple created above
    var found=false
    for key in diagCallBacks.keys {
      let act = diagCallBacks[key]
      if act!.returnKey() == tupple {
        found=true
        act!.performAction(["vehiclemessage":rsp] as NSDictionary)
      }
    }
    // otherwise use the default callback if it exists
    if !found ,let act = defaultDiagCallBack {
        
        act.performAction(["vehiclemessage":rsp] as NSDictionary)
    }
  }*/
  
    /*fileprivate func protobufCanMessage(msg : Openxc.VehicleMessage){
    // build CAN response message
    let rsp : VehicleCanResponse = VehicleCanResponse()
        if let timestamp = msg.timestamp{
                 rsp.timeStamp = Int(truncatingIfNeeded:timestamp)
             }
    //rsp.timeStamp = Int(truncatingIfNeeded:msg.timestamp)
    rsp.bus = Int(msg.canMessage.bus)
    rsp.id = Int(msg.canMessage.id)
    rsp.data = String(data:msg.canMessage.data as Data,encoding: String.Encoding.utf8)! as NSString
    
    // TODO: remove debug statement?
    vmlog("CAN bus:\(rsp.bus) status:\(rsp.id) payload:\(rsp.data)")
    /////////////////////////////////
    
    
    // build the key that identifies this CAN response
    // bus-id
    let tupple = "\(String(rsp.bus))-\(String(rsp.id))"
    
    // look for a specific callback for this CAN response based on tupple created above
    var found=false
    for key in canCallBacks.keys {
      let act = canCallBacks[key]
      if act!.returnKey() as String == tupple {
        found=true
        act!.performAction(["vehiclemessage":rsp] as NSDictionary)
      }
    }
    // otherwise use the default callback if it exists
    if !found , let act = defaultCanCallBack {
     
        act.performAction(["vehiclemessage":rsp] as NSDictionary)
     
    }
  }*/
  

  ////////////////
  // JSON decoding
  /////////////////
  fileprivate func jsonDecoding(data_chunk:NSMutableData){
    do {
      
      // decode json
      let json = try JSONSerialization.jsonObject(with: data_chunk as Data, options: .mutableContainers) as! [String:AnyObject]
        print("After json decoding \(json)" as Any)
      // every message will have a timestamp
      
      //Ranjan:  Added NSNumber in timestamp to parse as it is in number format then convert nsnumber to integer as per requirment.
      var timestamp : NSInteger = 0
      var timestamp1 : NSNumber = 0
      if json["timestamp"] != nil {
        timestamp1 = json["timestamp"]  as! NSNumber
        timestamp = NSInteger(timestamp1.int64Value)
        // NSLog("%d",timestamp)
      }
      
      
      // insert a delay if we're reading from a tracefile
        self.traceFileDelay(timestamp:timestamp)
      
      // evented measurement rsp
      ///////////////////
      // evented measuerment messages will have an "event" key
      if let event = json["event"] as? NSString {
         vmlog(event)
        self.Measurementrsp(json:json as [String:AnyObject],timestamp:timestamp)
      }

        // measurement rsp
        ///////////////////
        // normal measuerment messages will have an "name" key (but no "event" key)
      else if let name = json["name"] as? NSString {
        
        vmlog(name)
        self.Measurementrsp(json:json as [String:AnyObject],timestamp:timestamp)
      }
        
        // command rsp
        ///////////////////
        // command response messages will have a "command_response" key
      else if let cmd_rsp = json["command_response"] as? NSString {
        let myValue = json["command_response"] as? NSString
        print(myValue as Any)
        if (myValue != "diagnostic_request") {
        self.commandResponse(timestamp: timestamp,cmd_rsp:cmd_rsp,json: json as [String:AnyObject])
      }
        
      }
        
        
        // diag rsp or CAN message
        ///////////////////
        // both diagnostic response and CAN response messages have an "id" key
      else if let id = json["id"] as? NSInteger {
        print("JSON ID = \(id) "as Any)
        self.canMessagersp(json: json as [String:AnyObject],timestamp: timestamp,id:id)
        
      } else {
        // what the heck is it??
        
        if let id = json["message_id"] as? NSInteger {
            self.diagSingleFrameMessagersp(json: json as [String : AnyObject], timestamp: timestamp, id: id)
        }
        if let act = managerCallBack {
          act.performAction(["status":VehicleManagerStatusMessage.ble_RX_DATA_PARSE_ERROR.rawValue] as NSMutableDictionary)
        }
        
      }

      // if trace file output is enabled, create a string from the message
      // and send it to the trace file writer
        vmlog(TraceFileManager.sharedInstance.traceFileSinkEnabled)
      if (TraceFileManager.sharedInstance.traceFileSinkEnabled) {
        let str = String(data: data_chunk as Data,encoding: String.Encoding.utf8)
        TraceFileManager.sharedInstance.traceFileWriter(str!)
      }
      
      
      
      // Keep a count of how many messages were received in total
      // since connection. Can be used by the client app.
      BluetoothManager.sharedInstance.messageCount += 1
      
      
      
    } catch {
      // the json decode failed for some reason, usually data lost in connection
      vmlog("bad json")
      //self.jsonMode = false
      if let act = managerCallBack {
        act.performAction(["status":VehicleManagerStatusMessage.ble_RX_DATA_PARSE_ERROR.rawValue] as NSMutableDictionary)
      }
    }
  }
  
    func traceFileDelay(timestamp:NSInteger){
        // and we're tracking the timestamps in the file to
        // decide when to send the next message
        if TraceFileManager.sharedInstance.traceFileSourceTimeTracking {
          let msTimeNow = Int(Date.timeIntervalSinceReferenceDate*1000)
          if TraceFileManager.sharedInstance.traceFileSourceLastMsgTime == 0 {
            // first time
            TraceFileManager.sharedInstance.traceFileSourceLastMsgTime = timestamp
            TraceFileManager.sharedInstance.traceFileSourceLastActualTime = msTimeNow

          }
          let msgDelta = timestamp - TraceFileManager.sharedInstance.traceFileSourceLastMsgTime
          let actualDelta = msTimeNow - TraceFileManager.sharedInstance.traceFileSourceLastActualTime
          let deltaDelta : Double = (Double(msgDelta) - Double(actualDelta))/1000.0
          if deltaDelta > 0 {
            Thread.sleep(forTimeInterval: deltaDelta)
          }

          TraceFileManager.sharedInstance.traceFileSourceLastMsgTime = timestamp
          TraceFileManager.sharedInstance.traceFileSourceLastActualTime = msTimeNow

        }
    }
  // evented measurement rsp
  ///////////////////
  // evented measuerment messages will have an "event" key
  fileprivate func eventedMeasurementrsp(json:[String:AnyObject],event:NSString,timestamp:NSInteger){
    
    
    // extract other keys from message
    let name = json["name"] as! NSString
    let value : AnyObject = json["value"] ?? NSNull()
    
    // build measurement message
    let rsp : VehicleMeasurementResponse = VehicleMeasurementResponse()
    rsp.timeStamp = timestamp
    rsp.name = name
    rsp.value = value
    rsp.isEvented = true
    rsp.event = event
    
    // capture this message into the dictionary of latest messages
    //latestVehicleMeasurements.setValue(rsp, forKey:name as String)
    latestVehicleMeasurements[name] = rsp
    
    // look for a specific callback for this measurement name
    var found=false
    for key in measurementCallBacks.keys {
      let act = measurementCallBacks[key]
      if act!.returnKey() == name {
        found=true
        act!.performAction(["vehiclemessage":rsp] as NSDictionary)
      }
    }
    // otherwise use the default callback if it exists
    if !found, let act = defaultMeasurementCallBack {
    
        act.performAction(["vehiclemessage":rsp] as NSDictionary)
      
    }
  }
  

  // measurement rsp
  ///////////////////
  // normal measuerment messages will have an "name" key (but no "event" key)
  fileprivate func Measurementrsp(json:[String:AnyObject],timestamp:NSInteger){
    
    // extract other keys from message
    let name = json["name"] as! NSString
    let value : AnyObject = json["value"] ?? NSNull()
    
    // build measurement message
    let rsp : VehicleMeasurementResponse = VehicleMeasurementResponse()
    rsp.value = value
    rsp.timeStamp = timestamp
    rsp.name = name
    
    // capture this message into the dictionary of latest messages
    //latestVehicleMeasurements.setValue(rsp, forKey:name as String)
    latestVehicleMeasurements[name] = rsp
    
    // look for a specific callback for this measurement name
    var found=false
    for key in measurementCallBacks.keys {
      let act = measurementCallBacks[key]
      if act!.returnKey() == name {
        found=true
        act!.performAction(["vehiclemessage":rsp] as NSDictionary)
      }
    }
    // otherwise use the default callback if it exists
    if !found,let act = defaultMeasurementCallBack {
      
        act.performAction(["vehiclemessage":rsp] as NSDictionary)
      
    }
  }
  
  // command rsp
  ///////////////////
  // command response messages will have a "command_response" key
  fileprivate func commandResponse(timestamp:NSInteger,cmd_rsp:NSString,json:[String:AnyObject]){
  
  
    // extract other keys from message
    var message : NSString = ""
    if let messageX = json["message"] as? NSString {
      message = messageX
    }
    var status : Bool = false
    if let statusX = json["status"] as? Bool {
      status = statusX
    }
    
    // build command response message
    let rsp : VehicleCommandResponse = VehicleCommandResponse()
    rsp.timeStamp = timestamp
    rsp.message = message
    rsp.command_response = cmd_rsp
    rsp.status = status
    
    // First see if the default command callback is defined. If it is
    // then that takes priority. This will be the most likely use case,
    // with a single command response handler.
    if let act = defaultCommandCallBack {
      act.performAction(["vehiclemessage":rsp] as NSDictionary)
    }
      // Otherwise, grab the first callback message in the list of command callbacks.
      // They will be in order relative to when the commands are sent (VI guarantees
      // to response order). We need to check that the list of command callbacks
      // actually has something in it here (check for count>0) because if we're
      // receiving command responses via a trace file, then there was never an
      // actual command request message sent to the VI.
    else if bleTransmitCommandCallBack.count > 0 {
      let ta : TargetAction = bleTransmitCommandCallBack.removeFirst()
      let s : String = bleTransmitCommandToken.removeFirst()
      ta.performAction(["vehiclemessage":rsp,"key":s] as NSDictionary)
    }
  }
  
  // diag rsp or CAN message
    
    fileprivate func diagSingleFrameMessagersp(json:[String:AnyObject],timestamp:NSInteger,id:NSInteger){
        print("single Frame rsp\(json)")
        let frame = json["frame"] as?  NSInteger
        if (frame != -1){
        if let payloadX = json["payload"] as? String,frame == 0   {
                multiFramePayload = payloadX
                print("payload : \(multiFramePayload)")
            return
                }
        }else{
        let success = json["success"] as? Bool
        // extract other keys from message
        var bus : NSInteger = 0
        if let busX = json["bus"] as? NSInteger {
          bus = busX
        }
        var mode : NSInteger = 0
        if let modeX = json["mode"] as? NSInteger {
          mode = modeX
        }
        var pid : NSInteger?
        if let pidX = json["pid"] as? NSInteger {
          pid = pidX
        }
        

        var payload : String = ""
        if let payloadX = json["payload"] as? String {
          payload = multiFramePayload  + payloadX
          print("payload : \(payload)")
          
        }
        var value : NSInteger?
        if let valueX = json["value"] as? NSInteger {
          value = valueX
        }
        
        // build diag response message
        let rsp : VehicleDiagnosticResponse = VehicleDiagnosticResponse()
        rsp.timeStamp = timestamp
        rsp.bus = bus
        rsp.message_id = id
        rsp.mode = mode
        rsp.pid = pid!
        rsp.success = success!
        rsp.payload = payload
        rsp.value = value!
        
         //Adde for NRC fix
        self.nrcFix(success:success!,json: json,rsp:rsp)

        
        // build the key that identifies this diagnostic response
        // bus-id-mode-[X or pid]
        let tupple : NSMutableString = ""
        var newid = 0
        if(self.lastReqMsg_id == 2015) { //exception for 7df
          newid = self.lastReqMsg_id
        } else {
          newid=id-8
        }
        tupple.append("\(String(bus))-\(String(newid))-\(String(mode))-")
        if pid != nil {
          tupple.append(String(describing: pid))
        } else {
          tupple.append("X")
        }

        ////////////////////////////
        
        // look for a specific callback for this diag response based on tupple created above
        var found=false
        for key in diagCallBacks.keys {
          let act = diagCallBacks[key]
          if act!.returnKey() == tupple {
            found=true
            act!.performAction(["vehiclemessage":rsp] as NSDictionary)
          }
        }
        // otherwise use the default callback if it exists
        if !found ,let act = defaultDiagCallBack{
          
            act.performAction(["vehiclemessage":rsp] as NSDictionary)

        }
        
        }
    }
    
    
  ///////////////////
  // both diagnostic response and CAN response messages have an "id" key
  fileprivate func canMessagersp(json:[String:AnyObject],timestamp:NSInteger,id:NSInteger){

    
    // only diagnostic response messages have "success"
    if let success = json["success"] as? Bool {
      
  
       self.canMessageWithId(json: json, timestamp: timestamp, id: id, success: success)
      
      
      // CAN messages have "data"
    } else if let data = json["data"] as? NSString {
      
      // extract other keys from message
      var bus : NSInteger = 0
      if let busX = json["bus"] as? NSInteger {
        bus = busX
      }
      
      // build CAN response message
      let rsp : VehicleCanResponse = VehicleCanResponse()
      rsp.timeStamp = timestamp
      rsp.bus = bus
      rsp.id = id
      rsp.data = data
      
      // TODO: remove debug statement?
      vmlog("CAN bus:\(bus) status:\(id) payload:\(data)")
      /////////////////////////////////
      
      
      // build the key that identifies this CAN response
      // bus-id
      let tupple = "\(String(bus))-\(String(id))"
      
      // look for a specific callback for this CAN response based on tupple created above
      var found=false
      for key in canCallBacks.keys {
        let act = canCallBacks[key]
        if act!.returnKey() as String == tupple {
          found=true
          act!.performAction(["vehiclemessage":rsp] as NSDictionary)
        }
      }
      // otherwise use the default callback if it exists
      if !found , let act = defaultCanCallBack{
        
          act.performAction(["vehiclemessage":rsp] as NSDictionary)

        
      }
      
    } else {
      // should never get here!
      if let act = managerCallBack {
        act.performAction(["status":VehicleManagerStatusMessage.ble_RX_DATA_PARSE_ERROR.rawValue] as NSMutableDictionary)
      }
    }
  }
  
  fileprivate func canMessageWithId(json:[String:AnyObject],timestamp:NSInteger,id:NSInteger,success:Bool){
    // extract other keys from message
    var bus : NSInteger = 0
    if let busX = json["bus"] as? NSInteger {
      bus = busX
    }
    var mode : NSInteger = 0
    if let modeX = json["mode"] as? NSInteger {
      mode = modeX
    }
    var pid : NSInteger?
    if let pidX = json["pid"] as? NSInteger {
      pid = pidX
    }
    

    var payload : String = ""
    if let payloadX = json["payload"] as? String {
      payload = payloadX
      print("payload : \(payload)")
      
    }
    var value : NSInteger?
    if let valueX = json["value"] as? NSInteger {
      value = valueX
    }
    
    // build diag response message
    let rsp : VehicleDiagnosticResponse = VehicleDiagnosticResponse()
    rsp.timeStamp = timestamp
    rsp.bus = bus
    rsp.message_id = id
    rsp.mode = mode
    rsp.pid = pid!
    rsp.success = success
    rsp.payload = payload
    rsp.value = value!
    
     //Adde for NRC fix
    self.nrcFix(success:success,json: json,rsp:rsp)

    
    // build the key that identifies this diagnostic response
    // bus-id-mode-[X or pid]
    let tupple : NSMutableString = ""
    var newid = 0
    if(self.lastReqMsg_id == 2015) { //exception for 7df
      newid = self.lastReqMsg_id
    } else {
      newid=id-8
    }
    tupple.append("\(String(bus))-\(String(newid))-\(String(mode))-")
    if pid != nil {
      tupple.append(String(describing: pid))
    } else {
      tupple.append("X")
    }

    ////////////////////////////
    
    // look for a specific callback for this diag response based on tupple created above
    var found=false
    for key in diagCallBacks.keys {
      let act = diagCallBacks[key]
      if act!.returnKey() == tupple {
        found=true
        act!.performAction(["vehiclemessage":rsp] as NSDictionary)
      }
    }
    // otherwise use the default callback if it exists
    if !found ,let act = defaultDiagCallBack{
      
        act.performAction(["vehiclemessage":rsp] as NSDictionary)

    }
  }
  // Uncomment the code when there will be a server URL and test the code
    func nrcFix(success:Bool,json:[String:AnyObject],rsp:VehicleDiagnosticResponse){
        if(!success){
          //success false, parse negative response code. For DID commands.
          if let nrcX = json["negative_response_code"] as? NSInteger{
            rsp.negative_response_code = nrcX
          }
        }
    }
  //Send data using trace URL
    @objc public func sendTraceURLData(urlName:String,rspdict:NSMutableDictionary,isdrrsp:Bool) {

    //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid
    //var base64String = "my fancy string".data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
    let urlName = urlName
    var traceArr = [AnyObject]()
    if !isdrrsp {
      for (key, value) in rspdict{
        let tempDict: [String:Any] = ["name":key ,"value":value ]
        traceArr.append(tempDict as AnyObject)
      }
    }else{
      traceArr.append(rspdict as AnyObject)
    }
    let url = URL(string: urlName)
    
    //now create the URLRequest object using the url object
    var request:URLRequest = URLRequest(url: url!)
    //create the session object
    let session = URLSession.shared
    
    do {
      // pass array to nsdata object and set it as request body
      
      let jsonData = try? JSONSerialization.data(withJSONObject: traceArr as Any)
      let jsonString = String(data: jsonData!, encoding: String.Encoding.utf8)
      let data = jsonString!.data(using: .utf8)!

      // the request is JSON
      request.httpMethod = "POST"
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
      request.httpBody = data

    }catch let error {
      print(error.localizedDescription)
    }
    
    //create dataTask using the session object to send data to the server
    let task = session.dataTask(with: request, completionHandler: { data, response, error in
      
      guard error == nil else {
        return
      }
      
      guard let data = data else {
        return
      }
      
      do {
        //create json object from data
        if let json = try JSONSerialization.jsonObject(with: data, options:.mutableContainers) as? [String:AnyObject] {
          print(json)
          
          // handle json...
        }
        
      } catch let error {
        print(error.localizedDescription)
      }
    })
    task.resume()
  }

  // Common function for parsing any received data into openXC messages.
  // The separator parameter allows data to be parsed when each message is
  // separated by different things, for example messages are separated by \0
  // when coming via BLE, and separated by 0xa when coming via a trace file
  // RXDataParser returns the timestamp of the parsed message out of convenience.
  
  //fileprivate to open
  open func RxDataParser(_ separator:UInt8) {


    ////////////////
    // Protobuf decoding
    /////////////////
    
    
    if !jsonMode && RxDataBuffer.length > 0 {
      var packetlenbyte:UInt8 = 0
      RxDataBuffer.getBytes(&packetlenbyte, length:MemoryLayout<UInt8>.size)
      let packetlen = Int(packetlenbyte)
      
      if RxDataBuffer.length > packetlen {
       // vmlog("found \(packetlen)B protobuf frame")
        let data_chunk : NSMutableData = NSMutableData()
        data_chunk.append(RxDataBuffer.subdata(with: NSMakeRange(1,packetlen)))
        
       // vmlog(data_chunk)
        
        self.protobufDecoding(data_chunk: data_chunk as NSMutableData,packetlen:packetlen)
        
        // Keep a count of how many messages were received in total
        // since connection. Can be used by the client app.
        BluetoothManager.sharedInstance.messageCount += 1
        
      }
      return
    }
    
    
    ////////////////
    // JSON decoding
    /////////////////
    
    
    // see if we can find a separator in the buffered data
    let sepdata = Data(bytes: UnsafePointer<UInt8>([separator] as [UInt8]), count: 1)
    let rangedata = NSMakeRange(0, RxDataBuffer.length)
    let foundRange = RxDataBuffer.range(of: sepdata, options:[], in:rangedata)
    
    // data parsing variables
    let data_chunk : NSMutableData = NSMutableData()
    let data_left : NSMutableData = NSMutableData()
    
    // here we check to see if the separator exists, and therefore that we
    // have a complete message ready to be extracted
    if foundRange.location != NSNotFound {
      // extract the entire message from the rx data buffer
      data_chunk.append(RxDataBuffer.subdata(with: NSMakeRange(0,foundRange.location)))
      // if there is leftover data in the buffer, make sure to keep it otherwise
      // the parsing will not work for the next message that is partially complete now
      if RxDataBuffer.length-1 > foundRange.location {
        data_left.append(RxDataBuffer.subdata(with: NSMakeRange(foundRange.location+1,RxDataBuffer.length-foundRange.location-1)))
        RxDataBuffer = data_left
      } else {
        RxDataBuffer = NSMutableData()
      }
      // TODO: remove this, just for debug
      let str = String(data: data_chunk as Data,encoding: String.Encoding.utf8)
      if str != nil {
        //          vmlog(str!)
      } else {
        vmlog("not UTF8")
      }
      /////////////////////////////////////
    }
    
    // do the actual parsing if we've managed to extract a full message
    if data_chunk.length > 0 {

      self.jsonDecoding(data_chunk:data_chunk)
      
      // Keep a count of how many messages were received in total
      // since connection. Can be used by the client app.
      
       BluetoothManager.sharedInstance.messageCount += 1
    }

  }
  public func calculateThroughput() -> (String) {
    //.. Code process

    let value = tempDataBuffer.length/5
    print(tempDataBuffer.length)
    tempDataBuffer.setData(NSMutableData() as Data)
    let result = String(value)
    return result
  }

}
