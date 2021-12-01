//
//  TraceFileManager.swift
//  openxc-ios-framework
//
//  Created by Ranjan, Kumar sahu (K.) on 21/05/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import UIKit

open class TraceFileManager: NSObject {
  
  static let _sharedInstance = TraceFileManager()
  
  // config variable determining whether trace output is generated
  open var traceFileSinkEnabled: Bool = false
  // config variable holding trace output file name
  fileprivate var traceFileSinkName: NSString = ""
  
  // config variable determining whether trace input is used instead of BTLE data
  open var traceFileSourceEnabled: Bool = false
  // config variable holding trace input file name
  fileprivate var traceFileSourceName: NSString = ""
  // private timer for trace input message send rate
  fileprivate var traceFileSourceTimer: Timer = Timer()
  // private file handle to trace input file
  fileprivate var traceFileSourceHandle: FileHandle?
  // private variable holding timestamps when last message received
  open var traceFileSourceLastMsgTime: NSInteger = 0
  open var traceFileSourceLastActualTime: NSInteger = 0
  // this tells us we're tracking the time held in the trace file
  open var traceFileSourceTimeTracking: Bool = false
  // config for outputting debug messages to console
  fileprivate var managerDebug : Bool = false
  //open var traceDisableLoopOn = false
  // optional variable holding callback for VehicleManager status updates
  fileprivate var managerCallBack: TargetAction?
  
  // Initialization
  static public let sharedInstance: TraceFileManager = {
    
    return TraceFileManager()
    
  }()
  // private debug log function gated by the debug setting
  fileprivate func vmlog(_ strings:Any...) {
    if managerDebug {
      let d = Date()
      let df = DateFormatter()
      df.dateFormat = "[H:m:ss.SSS]"
      //print(df.string(from: d),terminator:"")
      //print(" ",terminator:"")
      for string in strings {
        print(string,terminator:"")
      }
      print("")
    }
  }
  // change the debug config for the VM
  open func setManagerDebug(_ on:Bool) {
    managerDebug = on
  }
  
  // tell the VM to enable output to trace file
  open func enableTraceFileSink(_ filename:NSString) -> Bool {
    
    // check that file sharing is enabled in the bundle
    if let fs : Bool = Bundle.main.infoDictionary?["UIFileSharingEnabled"] as? Bool {
      if fs == true {
        vmlog("file sharing ok!")
      } else {
        vmlog("file sharing false!")
        return false
      }
    } else {
      vmlog("no file sharing key!")
      return false
    }
    
    // save the trace file name
    traceFileSinkEnabled = true
    
    // append date to filename
    let d = Date()
    let df = DateFormatter()
    df.dateFormat = "dd-MM-yyyy HH-mm-ss"
    let datedFilename = (filename as String) + "-" + df.string(from: d)
    traceFileSinkName = datedFilename as NSString
    
    // find the file, and overwrite it if it already exists
    if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                     FileManager.SearchPathDomainMask.allDomainsMask, true).first {
      
      let path = URL(fileURLWithPath: dir).appendingPathComponent(traceFileSinkName as String).path
      
      vmlog("checking for file")
      if FileManager.default.fileExists(atPath: path) {
        vmlog("file detected")
        do {
          try FileManager.default.removeItem(atPath: path)
          vmlog("file deleted")
        } catch {
          vmlog("could not delete file")
          return false
        }
      } else {
        return false
      }
    } else {
      return false
    }
    
    
    
    return true
    
  }

  
  // turn off trace file output
  open func disableTraceFileSink() {
    
    traceFileSinkEnabled = false
    traceFileSourceHandle = nil
    traceFileSourceTimer.invalidate()
    VehicleManager.sharedInstance.isTraceFileConnected = false
    // notify the client app if the callback is enabled
    if let act = managerCallBack {
      act.performAction(["status":VehicleManagerStatusMessage.trace_SOURCE_END.rawValue] as NSMutableDictionary)
    }
    
  }
  
  // turn on trace file input instead of data from BTLE
  // specify a filename to read from, and a speed that lines
  // are read from the file in ms
  // If the speed is not specified, the framework will use the timestamp
  // values found in the trace file to determine when to send the next message
  open func enableTraceFileSource(_ filename:NSString, speed:NSInteger?=nil) -> Bool {
    
    // only allow a reasonable range of values for speed, not too fast or slow
    if speed != nil && (speed)! < 50 || (speed)! > 1000 {
        return false
    }
    
    // check for file sharing in the bundle
    if let fs : Bool = Bundle.main.infoDictionary?["UIFileSharingEnabled"] as? Bool {
      if fs == true {
        vmlog("file sharing ok!")
      } else {
        vmlog("file sharing false!")
        return false
      }
    } else {
      vmlog("no file sharing key!")
      return false
    }
    
    
    // check that the file exists
    if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                     FileManager.SearchPathDomainMask.allDomainsMask, true).first {
      
      let path = URL(fileURLWithPath: dir).appendingPathComponent(filename as String).path
      
      vmlog("checking for file")
      if FileManager.default.fileExists(atPath: path) {
        vmlog("file detected")
        
        // file exists, save file name for trace input
        traceFileSourceEnabled = true
        traceFileSourceName = filename
        
        // create a file handle for the trace input
        traceFileSourceHandle = FileHandle(forReadingAtPath:path)
        if traceFileSourceHandle == nil {
          vmlog("can't open filehandle")
          return false
        }
        self.checkFile(speed: speed)
  
        
        return true
        
      }
    }
    
    return false
    
  }
    func checkFile(speed:NSInteger?=nil){
        // create a timer to handle reading from the trace input filehandle
          // if speed parameter exists
          if speed != nil {
            let spdf:Double = Double(speed!) / 1000.0
            traceFileSourceTimer = Timer.scheduledTimer(timeInterval: spdf, target: self, selector: #selector(traceFileReader), userInfo: nil, repeats: true)
          } else {
            // if it doesn't exist, we're tracking the time held in the
            // trace file
            traceFileSourceTimeTracking = true
            traceFileSourceLastMsgTime = 0
            traceFileSourceLastActualTime = 0
            // call the timer as fast as possible, the data parser will sleep to delay the
            // messages when necessary
            traceFileSourceTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(traceFileReader), userInfo: nil, repeats: true)
          }
    }
  
  // turn off trace file input
  open func disableTraceFileSource() {
    
    traceFileSourceEnabled = false
    traceFileSourceHandle = nil
    traceFileSourceTimer.invalidate()
    VehicleManager.sharedInstance.isTraceFileConnected = false
    BluetoothManager.sharedInstance.connectionState = .notConnected
    // notify the client app if the callback is enabled
    if let act = managerCallBack {
      act.performAction(["status":VehicleManagerStatusMessage.trace_SOURCE_END.rawValue] as NSMutableDictionary)
    }
    
  }
  // Write the incoming string to the configured trace output file.
  // Make sure that there are no LF/CR in the parameter string, because
  // this method adds a CR automatically
  public func traceFileWriter (_ string:String) {
    
    vmlog("trace:",string)
    
    var traceOut = string
    
    traceOut.append("\n");
    
    // search for the trace output file
    if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                     FileManager.SearchPathDomainMask.allDomainsMask, true).first {
      let path = URL(fileURLWithPath: dir).appendingPathComponent(traceFileSinkName as String)
      
      // write the string to the trace output file
      do {
        let data = traceOut.data(using: String.Encoding.utf8)!
        if let fileHandle = try? FileHandle(forWritingTo: path) {
          defer {
            fileHandle.closeFile()
          }
          fileHandle.seekToEndOfFile()
          fileHandle.write(data)
        }
        else {
          // file handle open failed for some reason,
          // try writing to the file as a path url.
          // shouldn't reach this normally
          try data.write(to: path, options: .atomic)
        }
      }
      catch {
        // couldn't write to the trace output file
        if let act = managerCallBack {
          act.performAction(["status":VehicleManagerStatusMessage.trace_SINK_WRITE_ERROR.rawValue] as NSMutableDictionary)
        }
      }
      
    } else {
      // couldn't find trace output file
      if let act = managerCallBack {
        act.performAction(["status":VehicleManagerStatusMessage.trace_SINK_WRITE_ERROR.rawValue] as NSMutableDictionary)
      }
    }
    
    
  }
  
  // Read a chunk of data from the trace input file.
  // 20B is chosen as the chunk size to mirror the BLE data size.
  // Called by timer function when client app provides a speed value for
  // trace input file
  @objc fileprivate dynamic func traceFileReader() {
    //readDataToEndOfFile
    // if the trace file is enabled and open, read 20B
    if traceFileSourceEnabled && traceFileSourceHandle != nil {
      let rdData = traceFileSourceHandle!.readData(ofLength: 20)
      
      // we have read some data, append it to the rx data buffer
      if rdData.count > 0 {
        VehicleManager.sharedInstance.RxDataBuffer.append(rdData)
        // Try parsing the data that was added to the buffer. Use
        // LF as the message delimiter because that's what's used
        // in trace files.
        // update connection state to indicate that we're fully operational and receiving data
        BluetoothManager.sharedInstance.connectionState = .operational
        VehicleManager.sharedInstance.isTraceFileConnected = true
        VehicleManager.sharedInstance.RxDataParser(0x0a)
      } else {
        //This is condition for replaying trace file in loop  .
        let traceDisableLoopOn = UserDefaults.standard.bool(forKey: "disableTraceLoopOn")
        if (traceDisableLoopOn ){
            //This is for playing trace file once  .
            // There was no data read, so we're at the end of the
            // trace input file. Close the input file and timer
            vmlog("traceFilesource EOF")
            traceFileSourceHandle!.closeFile()
            traceFileSourceHandle = nil
            traceFileSourceTimer.invalidate()
            // notify the client app if the callback is enabled
            if let act = managerCallBack {
                act.performAction(["status":VehicleManagerStatusMessage.trace_SOURCE_END.rawValue] as NSMutableDictionary)
            }
        }else{
            traceFileSourceTimer.invalidate()
           self.traceFileRestart()
        }
      }
    }
  }
  open func traceFileRestart() {
     if (traceFileSourceName != ""){
       self.enableTraceFileSource(traceFileSourceName)
    }
}
    
}
