//
//  NetworkData.swift
//  openxc-ios-framework
//
//  Created by Ranjan, Kumar sahu (K.) on 08/01/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import UIKit
import ExternalAccessory

open class NetworkDataManager: NSObject ,StreamDelegate {

    
  static let sharedNetwork = NetworkDataManager()
    private var inputStream:  InputStream?
    private var outputStream: OutputStream?
    private var connecting:Bool
    var host: String?
    var port: Int?
    var theData : UInt8!
    var callBackHandler: ((Bool) -> ())?  = nil
    
    // Initialization
    static public let sharedInstance: NetworkDataManager = {
        let instance = NetworkDataManager()
        return instance
    }()
    fileprivate override init() {
        connecting = false
    }
    open func connect(ip:String, portvalue:Int, completionHandler: @escaping (_ success: Bool) -> ()) {
        host = ip
        port = portvalue
        self.callBackHandler = completionHandler
        Stream.getStreamsToHost(withName: host!, port: port!,inputStream: &inputStream, outputStream: &outputStream)
        
        //here we are going to calling a delegate function
        inputStream?.delegate = self
        outputStream?.delegate = self
        
        inputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream?.schedule(in: RunLoop.current, forMode:RunLoop.Mode.default)
        
        inputStream?.open()
        
        if ((outputStream?.open()) != nil){
            
        }else{
           
            VehicleManager.sharedInstance.isNetworkConnected = false
            if let act = VehicleManager.sharedInstance.managerCallBack {
                act.performAction(["status":VehicleManagerStatusMessage.networkDISCONNECTED.rawValue] as NSDictionary)
            }
        }
    }
    
    open func disconnectConnection(){
        inputStream?.close()
        outputStream?.close()
        VehicleManager.sharedInstance.isNetworkConnected = false
        if let act = VehicleManager.sharedInstance.managerCallBack {
            act.performAction(["status":VehicleManagerStatusMessage.networkDISCONNECTED.rawValue] as NSDictionary)
        }
    }
    
    public func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch (eventCode)
        {
        case Stream.Event.openCompleted:
            
            if(aStream == outputStream)
            {
                print("output:OutPutStream opened")
            }
            print("Input = openCompleted")
            break
        case Stream.Event.errorOccurred:
            if(aStream == outputStream)
            {
                self.callBackHandler!(false)
                print("output:Error Occurred\n")
                VehicleManager.sharedInstance.isNetworkConnected = false
                if let act = VehicleManager.sharedInstance.managerCallBack {
                    act.performAction(["status":VehicleManagerStatusMessage.networkDISCONNECTED.rawValue] as NSDictionary)
                }
            }
            print("Input : Error Occurred\n")
            break
            
        case Stream.Event.endEncountered:
            if(aStream == outputStream)
            {
                print("output:endEncountered\n")
            }
            print("Input = endEncountered\n")
            break
            
        case Stream.Event.hasSpaceAvailable:
            if(aStream == outputStream)
            {
                print("output:hasSpaceAvailable\n")
                //self.callbackHandler!(false)
            }
            print("Input = hasSpaceAvailable\n")
            break
            
        case Stream.Event.hasBytesAvailable:
            
            
            VehicleManager.sharedInstance.isNetworkConnected = true
            if let act = VehicleManager.sharedInstance.managerCallBack {
                act.performAction(["status":VehicleManagerStatusMessage.networkCONNECTED.rawValue] as NSDictionary)
            }
            self.callBackHandler!(true)
            
         
            self.checkDataBytes(aStream: aStream)
            
            break
            
        default:
            print("default block")
            
        }
        
    }
    
    func checkDataBytes(aStream: Stream)  {
        if aStream == inputStream
                   {
                       var buffer = [UInt8](repeating:0, count:20)
                       while (self.inputStream!.hasBytesAvailable)
                       {
                           let len = inputStream!.read(&buffer, maxLength: buffer.count)
                           
                           // If read bytes are less than 0 -> error
                           if len < 0
                           {
                               let error = self.inputStream!.streamError

                               //closeNetworkCommunication()
                           }
                           
                           if(len > 0)
                               //here it will check it out for the data sending from the server if it is greater than 0 means if there is a data means it will write
                           {
                               let messageFromServer = NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.utf8.rawValue)
                               let  msgdata = Data(bytes:buffer)
                               
                               if msgdata.count > 0 {
                                   VehicleManager.sharedInstance.RxDataBuffer.append(msgdata)
                                   VehicleManager.sharedInstance.RxDataParser(0x00)
                               }
                                   
                               else
                               {
                                   print("MessageFromServer = \(String(describing: messageFromServer))")
                                   
                               }
                           }
                       }
                   }
    }
}
