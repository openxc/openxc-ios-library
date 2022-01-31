//
//  Command.swift
//  openxc-ios-framework
//
//  Created by Kanishka, Vedi (V.) on 28/06/17.
//  Copyright © 2017 Ford Motor Company. All rights reserved.
//

import Foundation
//import SwiftProtobuf

public enum VehicleCommandType: NSString {
    case version
    case device_id
    case platform
    case passthrough
    case af_bypass
    case payload_format
    case predefined_odb2
    case modem_configuration
    case sd_mount_status
    case rtc_configuration
    case custom_command
    case get_Vin
}


open class VehicleCommandRequest : VehicleBaseMessage {
    public override init() {
        super.init()
        type = .commandResponse
    }
    open var command : VehicleCommandType = .version
    open var bus : NSInteger = 0
    open var enabled : Bool = false
    open var bypass : Bool = false
    open var format : NSString = ""
    open var server_host : NSString = ""
    open var server_port : NSInteger = 0
    open var unix_time : NSInteger = 0
}

open class VehicleCommandResponse : VehicleBaseMessage {
    public override init() {
        super.init()
        type = .commandResponse
    }
    open var command_response : NSString = ""
    open var message : NSString = ""
    open var status : Bool = false
    override func traceOutput() -> NSString {
        return "{\"timestamp\":\(timeStamp),\"command_response\":\"\(command_response)\",\"message\":\"\(message)\",\"status\":\(status)}" as NSString
    }
}


open class Command: NSObject {

    
    // MARK: Singleton Init
    // This signleton init allows mutiple controllers to access the same instantiation
    // of the VehicleManager. There is only a single instantiation of the VehicleManager
    // for the entire client app
    static public let sharedInstance: Command = {
        let instance = Command()
        return instance
    }()
    
    // config variable determining whether trace input is used instead of BTLE data
    fileprivate var traceFileSourceEnabled: Bool = false

    // BTLE transmit token increment variable
    fileprivate var bleTransmitSendToken: Int = 0

    // ordered list for storing callbacks for in progress vehicle commands
    fileprivate var bleTransmitCommandCallback = [TargetAction]()

    // mirrored ordered list for storing command token for in progress vehicle commands
    fileprivate var bleTransmitCommandToken = [String]()

    // config for protobuf vs json BLE mode, defaults to JSON
   // fileprivate var jsonMode : Bool = true


    // config for outputting debug messages to console
    fileprivate var managerDebug : Bool = false

    // data buffer for storing vehicle messages to send to BTLE
    fileprivate var bleTransmitDataBuffer: NSMutableArray! = NSMutableArray()
    
    var vm = VehicleManager.sharedInstance

    // 'default' command callback. If this is defined, it takes priority over any other callback
    fileprivate var defaultCommandCallback : TargetAction?
    // optional variable holding callback for VehicleManager status updates
    fileprivate var managerCallback: TargetAction?

    // private debug log function gated by the debug setting
    fileprivate func vmlog(_ strings:Any...) {
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

    
    open func sendCommand<T: AnyObject>(_ cmd:VehicleCommandRequest, target: T, action: @escaping (T) -> (NSDictionary) -> ()) -> String {
        vmlog("in sendCommand:target")
        
        // if we have a trace input file, ignore this request!
        if (traceFileSourceEnabled) {
            return ""
            
        }
        
        // save the callback in order, so we know which to call when responses are received
        bleTransmitSendToken += 1
        let key : String = String(bleTransmitSendToken)
        let act : TargetAction = TargetActionWrapper(key:key as NSString, target: target, action: action)
        bleTransmitCommandCallback.append(act)
        bleTransmitCommandToken.append(key)
        
        // common command send method
        sendCommandCommon(cmd)
        
        return key

    }
    
    // send a command message with no callback specified
    open func sendCommand(_ cmd:VehicleCommandRequest) {
        vmlog("in sendCommand")
        
        // if we have a trace input file, ignore this request!
        if (traceFileSourceEnabled) {
            return
            
        }
        
        // we still need to keep a spot for the callback in the ordered list, so
        // nothing gets out of sync. Assign the callback to the null callback method.
        bleTransmitSendToken += 1
        let key : String = String(bleTransmitSendToken)
        let act : TargetAction = TargetActionWrapper(key: "", target: VehicleManager.sharedInstance, action: VehicleManager.CallbackNull)
        bleTransmitCommandCallback.append(act)
        bleTransmitCommandToken.append(key)
        
        // common command send method
        sendCommandCommon(cmd)
        
    }
    
    // MARK: Class Functions
    
    // set the callback for VM status updates
    open func setManagerCallbackTarget<T: AnyObject>(_ target: T, action: @escaping (T) -> (NSDictionary) -> ()) {
        managerCallback = TargetActionWrapper(key:"", target: target, action: action)
    }
    // add a default callback for any measurement messages not include in specified callbacks
    open func setCommandDefaultTarget<T: AnyObject>(_ target: T, action: @escaping (T) -> (NSDictionary) -> ()) {
        defaultCommandCallback = TargetActionWrapper(key:"", target: target, action: action)
    }
    
    // clear default callback (by setting the default callback to a null method)
    open func clearCommandDefaultTarget() {
        defaultCommandCallback = nil
    }
    
    // common function for sending a VehicleCommandRequest
    func protobufSendCommand(cmd:VehicleCommandRequest){
        // in protobuf mode, build the command message
        var vehiclemessage = Openxc_VehicleMessage()
        vehiclemessage.type = .controlCommand
        
       // print(">>>>>>>>Comandtype\(cmd.command)")
        if cmd.command == .version {
            
            vehiclemessage.controlCommand.type = .version


        }
        if cmd.command == .device_id {
          
           vehiclemessage.controlCommand.type = .deviceID


          }
        if cmd.command == .platform {
          
           vehiclemessage.controlCommand.type = .platform


          }
        
        if cmd.command == .get_Vin {
          
           vehiclemessage.controlCommand.type = .getVin

          
         }
        
        if cmd.command == .passthrough {
            
            
            vehiclemessage.controlCommand.type = .passthrough
            vehiclemessage.controlCommand.passthroughModeRequest.bus = Int32(cmd.bus)
            vehiclemessage.controlCommand.passthroughModeRequest.enabled = cmd.enabled
            
        
        }
        if cmd.command == .af_bypass {
            
            vehiclemessage.controlCommand.type = .acceptanceFilterBypass
            vehiclemessage.controlCommand.acceptanceFilterBypassCommand.bus = Int32(cmd.bus)
            vehiclemessage.controlCommand.acceptanceFilterBypassCommand.bypass = cmd.bypass
            

        }
        if cmd.command == .payload_format {
            
            vehiclemessage.controlCommand.type = .payloadFormat
            
           if cmd.format == "json" {
            vehiclemessage.controlCommand.payloadFormatCommand.format = .json
               
            }
            if cmd.format == "protobuf" {
                vehiclemessage.controlCommand.payloadFormatCommand.format = .protobuf

            }
           

        }
        if cmd.command == .predefined_odb2 {
            
            vehiclemessage.controlCommand.type = .predefinedObd2Requests
            vehiclemessage.controlCommand.predefinedObd2RequestsCommand.enabled = cmd.bypass
           
            
        }
        if cmd.command == .modem_configuration {
 
            //        message->type = openxc_VehicleMessage_Type_CONTROL_COMMAND;
            //        message->control_command.type = openxc_ControlCommand_Type_PASSTHROUGH;
            //        message->control_command.passthrough_mode_request.bus = 1;
            //        message->control_command.passthrough_mode_request.enabled = 1;
            
//            _ = cbuild.setType(.modemConfiguration)
//            let cbuild2 = Openxc.ModemConfigurationCommand.Builder()
//            let srv = Openxc.ServerConnectSettings.Builder()
//            _ = srv.setHost(cmd.server_host as String)
//            _ = srv.setPort(UInt32(cmd.server_port))
//            _ = cbuild2.setServerConnectSettings(srv.buildPartial())
//            _ = cbuild.setModemConfigurationCommand(cbuild2.buildPartial())
        }
        if cmd.command == .rtc_configuration {
            
            vehiclemessage.controlCommand.type = .rtcConfiguration
            vehiclemessage.controlCommand.rtcConfigurationCommand.unixTime =  UInt32(cmd.unix_time)
           
        }
        if cmd.command == .sd_mount_status {
            
            vehiclemessage.controlCommand.type = .sdMountStatus
            
        }
        
        do
        {
            let binaryData:Data = try vehiclemessage.serializedData()
            let cdata2 = NSMutableData()
            let prepend : [UInt8] = [UInt8(binaryData.count)]
            cdata2.append(Data(bytes: UnsafePointer<UInt8>(prepend), count:1))
            cdata2.append(binaryData)
           
            self.vm.bleTransmitDataBuffer.add(cdata2)
            BluetoothManager.sharedInstance.bleSendFunction()
            //print("_____version data \(cdata2 as NSData)")
            BluetoothManager.sharedInstance.bleSendFunction()
            
        }catch{
            print(error)
        }
        
    }
    fileprivate func sendCommandCommon(_ cmd:VehicleCommandRequest) {
        
        if !self.vm.jsonMode {


            self.protobufSendCommand(cmd: cmd)
           
            
            return
        }
        
        // we're in json mode
        var cmdstr = ""
        // decode the command type and build the command depending on the command
        
        if cmd.command == .version || cmd.command == .device_id || cmd.command == .sd_mount_status || cmd.command == .platform || cmd.command == .get_Vin  {
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
            //print("timestamp is..",cmd.unix_time)
            cmdstr = "{\"command\":\"\(cmd.command.rawValue)\",\"unix_time\":\"\(cmd.unix_time)\"}\0"
        } else {
            // unknown command!
            return
            
        }
        
        // append to tx buffer
        bleTransmitDataBuffer.add(cmdstr.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        self.vm.bleTransmitDataBuffer = bleTransmitDataBuffer
        
        // trigger a BLE data send
        BluetoothManager.sharedInstance.bleSendFunction()
        //BLESendFunction()
        
    }
  
  open func customCommand(jsonString:String) {
    
    // if we have a trace input file, ignore this request!
    if (traceFileSourceEnabled) {
        return
        
    }
    
    // we still need to keep a spot for the callback in the ordered list, so
    // nothing gets out of sync. Assign the callback to the null callback method.
    bleTransmitSendToken += 1
    let key : String = String(bleTransmitSendToken)
    let act : TargetAction = TargetActionWrapper(key: "", target: VehicleManager.sharedInstance, action: VehicleManager.CallbackNull)
    bleTransmitCommandCallback.append(act)
    bleTransmitCommandToken.append(key)
    // we're in json mode
    //var cmdstr = ""
    // build the command json
    // cmdstr = jsonString
    // append to tx buffer
    // append to tx buffer
    var cmdstr = ""
    cmdstr = jsonString + "\0"
    self.vm.bleTransmitDataBuffer.add(cmdstr.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
    
    // trigger a BLE data send
    BluetoothManager.sharedInstance.bleSendFunction()
  }

}
