//
//  DiagViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework

class DiagnosticViewController: UIViewController, UITextFieldDelegate {
    
    // UI outlets
    @IBOutlet weak var busSegment: UISegmentedControl!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var modeField: UITextField!
    @IBOutlet weak var pidField: UITextField!
    @IBOutlet weak var payloadField: UITextField!
    @IBOutlet weak var requestButton: UIButton!
    
    @IBOutlet weak var lastRequest: UILabel!
    @IBOutlet weak var responseText: UITextView!
    
    var dashDict: NSMutableDictionary!
    var vm: VehicleManager!
    var bm : BluetoothManager!
    var cmd : VehicleDiagnosticRequest!
    // string array holding last X diag responses
    var responseStrings : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // grab VM instance
        vm = VehicleManager.sharedInstance
        bm = BluetoothManager.sharedInstance
        // set default diag response target
        vm.setDiagnosticDefaultTarget(self, action: DiagnosticViewController.default_diag_rsp)
        // set custom target for specific Diagnostic request
        vm.addDiagnosticTarget([1,2015,1], target: self, action: DiagnosticViewController.new_diag_rsp)
        vm.setManagerCallbackTarget(self, action: DiagnosticViewController.manager_status_updates)
        
        idField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        modeField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        pidField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    
    }
    
    @objc func textFieldDidChange(textField: UITextField){
          let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
          if  text!.count > 3 {
              switch textField{
              case idField:
                  checkMaxLength(textField: idField , maxLength: 3)
              case modeField:
                  checkMaxLength(textField: modeField , maxLength: 3)
                 
              default:
                  break
              }
          }
        if  text!.count > 4 {
             checkMaxLength(textField: pidField , maxLength: 4)
        }
          else{

          }
          
      }
    private func checkMaxLength(textField: UITextField!, maxLength: Int) {
           if (textField.text!.count > maxLength) {
               textField.deleteBackward()
           }
       }
    func manager_status_updates(_ rsp:NSDictionary) {
        // extract the status message
        let status = rsp.object(forKey: "status") as! Int
        let msg = VehicleManagerStatusMessage(rawValue: status)
        if (msg==VehicleManagerStatusMessage.c5DISCONNECTED && UserDefaults.standard.bool(forKey: "powerDropChange")) {
                powerDrop()
        }
    }
    @objc func powerDrop(){
        AlertHandling.sharedInstance.showToast(controller: self, message: "BLE Power Droped", seconds: 3)
    }
    // method for custom taregt - specific diagnostic request
    func new_diag_rsp(_ rsp:NSDictionary) {
        print("in new diag response")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if(!bm.isBleConnected){
            AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMsg, withMessage:errorMsgBLE)
        }
    }
    func default_diag_rsp(_ rsp:NSDictionary) {
        
        if UserDefaults.standard.bool(forKey: "uploadTaraceOn") {
            self.sendTraceURLData(rsp: rsp)
        }
        // extract the diag resp message
        let vr = rsp.object(forKey: "vehiclemessage") as! VehicleDiagnosticResponse
        
        // create the string we want to show in the received messages UI
        var newTxt = "bus:"+vr.bus.description+" id:0x"+String(format:"%x",vr.message_id)+" mode:0x"+String(format:"%x",vr.mode)+"timestamp"+String(vr.timeStamp)
        if vr.pid != 0 {
            newTxt = newTxt+" pid:0x"+String(format:"%x",vr.pid)
        }
        newTxt = newTxt+" success:"+vr.success.description
        if vr.value != 0 {
            newTxt = newTxt+" value:"+vr.value.description
            
        }else{
            newTxt = newTxt+" payload:"+(vr.payload.description)
        }
        
        
        // save only the 5 response strings
        if responseStrings.count>5 {
            responseStrings.removeFirst()
        }
        // append the new string
        responseStrings.append(newTxt)
        
        // reload the label with the update string list
        DispatchQueue.main.async {
            self.responseText.text = self.responseStrings.joined(separator: "\n")
            self.requestButton.isEnabled = true
        }
        
        print("Daignostic Value..........\(self.responseStrings)")
    }
    
    @objc func sendTraceURLData(rsp:NSDictionary) {
        let vr = rsp.object(forKey: "vehiclemessage") as! VehicleDiagnosticResponse
        
        dashDict.setObject(vr.bus.description,forKey: "bus" as NSCopying)
        dashDict.setObject(String(format:"%x",vr.message_id),forKey: "id" as NSCopying)
        dashDict.setObject(String(format:"%x",vr.success.description),forKey: "success" as NSCopying)
        if vr.pid != 0 {
            dashDict.setObject(String(format:"%x",vr.pid),forKey: "pid" as NSCopying)
        }
        if vr.value != 0 {
            dashDict.setObject(vr.value.description,forKey: "value" as NSCopying)
            
        }else{
            dashDict.setObject(vr.payload.description,forKey: "payload" as NSCopying)
        }
        
        if let urlname = (UserDefaults.standard.value(forKey: "traceURLname") as? String) {
            vm.sendTraceURLData(urlName:urlname,rspdict: dashDict , isdrrsp: true)
        }
        
    }
    
    // text view delegate to clear keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    
    // TODO radio button for bus
    // diag send button hit
    @IBAction func sendHit(_ sender: AnyObject) {
        
        // hide keyboard when the send button is hit
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        
        self.bluetoothCheck()
        
        // create an empty diag request
        cmd = VehicleDiagnosticRequest()
        
        // look at segmented control for bus
        cmd.bus = busSegment.selectedSegmentIndex + 1
        
        // check that the msg id field is valid
        self.checkMsgIdField(cmd: cmd)
        // check that the mode field is valid
        if let mode = modeField.text as String? {
            let modetrim = mode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if modetrim=="" {
                lastRequest.text = "Invalid command : need a mode"
                return
            }
            if let modeInt = Int(modetrim,radix:16) as NSInteger? {
                cmd.mode = modeInt
            } else {
                lastRequest.text = "Invalid command : mode should be hex number (with no leading 0x)"
                return
            }
        } else {
            lastRequest.text = "Invalid command : need a mode"
            return
        }
        
        // check that the pid field is valid (or empty)
        if let pid = pidField.text as String? {
            let pidtrim = pid.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if (pidtrim=="") {
                // this is ok, it's optional
            } else if let pidInt = Int(pidtrim,radix:16) as NSInteger? {
                cmd.pid = pidInt
            } else {
                lastRequest.text = "Invalid command : pid should be hex number (with no leading 0x)"
                return
            }
        }

        //TODO: add payload in diag request
        self.addPayload(cmd: cmd)
        
        // Get the Unix timestamp
        let timestamp = NSDate().timeIntervalSince1970
        cmd.timeStamp = NSInteger(timestamp)
        
        
        // send the diag request
        vm.sendDiagReq(cmd)
        
        // update the last request sent label
        lastRequest.text = "bus:"+String(cmd.bus)+" id:0x"+idField.text!+" mode:0x"+modeField.text!+"timestamp"+String(timestamp)
        if cmd.pid != nil {
            lastRequest.text = lastRequest.text!+" pid:0x"+pidField.text!
        }
        if !cmd.payload.isEqual(to: "") {
            lastRequest.text = lastRequest.text!+" payload:"+payloadField.text!
            requestButton.isEnabled = false
        }
    }
    func addPayload(cmd:VehicleDiagnosticRequest)  {
         // let cmd = VehicleDiagnosticRequest()
        if let mload = payloadField.text as String? {
            let mloadtrim = mload.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if mloadtrim=="" {
                // its optional
            }
            if mloadtrim.count%2==0 { //payload must be even length
                
                let appendedStr = "0x" + mloadtrim
                
                cmd.payload = appendedStr as NSString
            }
        } else {
            lastRequest.text = "Invalid command : payload should be even length"
            return
        }
    }
    func checkMsgIdField(cmd:VehicleDiagnosticRequest)  {
        
            if let mid = idField.text as String? {
            let midtrim = mid.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if midtrim=="" {
                lastRequest.text = "Invalid command : need a message_id"
                return
            }
            if let midInt = Int(midtrim,radix:16) as NSInteger? {
                cmd.message_id = midInt
            } else {
                lastRequest.text = "Invalid command : message_id should be hex number (with no leading 0x)"
                return
            }
        } else {
            lastRequest.text = "Invalid command : need a message_id"
            return
        }
    }
    func bluetoothCheck()  {
         // if the VM isn't operational, don't send anything
               if bm.connectionState != VehicleManagerConnectionState.operational {
                   lastRequest.text = "Not connected to VI"
                   return
               }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (string.containsValidCharacter)
    }
}
