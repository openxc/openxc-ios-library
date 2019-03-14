//
//  DiagViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework

class DiagViewController: UIViewController, UITextFieldDelegate {

  // UI outlets
  @IBOutlet weak var bussel: UISegmentedControl!
  @IBOutlet weak var idField: UITextField!
  @IBOutlet weak var modeField: UITextField!
  @IBOutlet weak var pidField: UITextField!
  @IBOutlet weak var ploadField: UITextField!
  @IBOutlet weak var requestBtn: UIButton!
    
  @IBOutlet weak var lastReq: UILabel!
  @IBOutlet weak var rspText: UITextView!
    
  var dashDict: NSMutableDictionary!
  var vm: VehicleManager!
    var bm : BluetoothManager!
  // string array holding last X diag responses
  var rspStrings : [String] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // grab VM instance
    vm = VehicleManager.sharedInstance
    bm = BluetoothManager.sharedInstance
    // set default diag response target
    vm.setDiagnosticDefaultTarget(self, action: DiagViewController.default_diag_rsp)
    // set custom target for specific Diagnostic request
    vm.addDiagnosticTarget([1,2015,1], target: self, action: DiagViewController.new_diag_rsp)

    
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
            
            AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMSG, withMessage:errorMsgBLE)
        }
    }
  func default_diag_rsp(_ rsp:NSDictionary) {
    
     if UserDefaults.standard.bool(forKey: "uploadTaraceOn") {
        self.sendTraceURLData(rsp: rsp)
    }
    // extract the diag resp message
    let vr = rsp.object(forKey: "vehiclemessage") as! VehicleDiagnosticResponse
    
    // create the string we want to show in the received messages UI
    var newTxt = "bus:"+vr.bus.description+" id:0x"+String(format:"%x",vr.message_id)+" mode:0x"+String(format:"%x",vr.mode)+"timestamp"+String(vr.timestamp)
    if vr.pid != nil {
        newTxt = newTxt+" pid:0x"+String(format:"%x",vr.pid!)
    }
    newTxt = newTxt+" success:"+vr.success.description
    if vr.value != nil {
        newTxt = newTxt+" value:"+vr.value!.description
        
    }else{
        newTxt = newTxt+" payload:"+(vr.payload.description)
    }
   
    
    // save only the 5 response strings
    if rspStrings.count>5 {
        rspStrings.removeFirst()
    }
    // append the new string
    rspStrings.append(newTxt)
    
    // reload the label with the update string list
    DispatchQueue.main.async {
        self.rspText.text = self.rspStrings.joined(separator: "\n")
        self.requestBtn.isEnabled = true
    }

    print("Daignostic Value..........\(self.rspStrings)")
  }
  
    @objc func sendTraceURLData(rsp:NSDictionary) {
        let vr = rsp.object(forKey: "vehiclemessage") as! VehicleDiagnosticResponse
        
        dashDict.setObject(vr.bus.description,forKey: "bus" as NSCopying)
        dashDict.setObject(String(format:"%x",vr.message_id),forKey: "id" as NSCopying)
        dashDict.setObject(String(format:"%x",vr.success.description),forKey: "success" as NSCopying)
        if vr.pid != nil {
            dashDict.setObject(String(format:"%x",vr.pid!),forKey: "pid" as NSCopying)
        }
        if vr.value != nil {
            dashDict.setObject(vr.value!.description,forKey: "value" as NSCopying)
            
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
    
    // if the VM isn't operational, don't send anything
    if bm.connectionState != VehicleManagerConnectionState.operational {
        lastReq.text = "Not connected to VI"
        return
    }
    
    // create an empty diag request
    let cmd = VehicleDiagnosticRequest()
    
    // look at segmented control for bus
    cmd.bus = bussel.selectedSegmentIndex + 1
    
    // check that the msg id field is valid
    if let mid = idField.text as String? {
        let midtrim = mid.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if midtrim=="" {
            lastReq.text = "Invalid command : need a message_id"
            return
        }
        if let midInt = Int(midtrim,radix:16) as NSInteger? {
            cmd.message_id = midInt
        } else {
            lastReq.text = "Invalid command : message_id should be hex number (with no leading 0x)"
            return
        }
    } else {
        lastReq.text = "Invalid command : need a message_id"
        return
    }
    // check that the mode field is valid
    if let mode = modeField.text as String? {
        let modetrim = mode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if modetrim=="" {
            lastReq.text = "Invalid command : need a mode"
            return
        }
        if let modeInt = Int(modetrim,radix:16) as NSInteger? {
            cmd.mode = modeInt
        } else {
            lastReq.text = "Invalid command : mode should be hex number (with no leading 0x)"
            return
        }
    } else {
        lastReq.text = "Invalid command : need a mode"
        return
    }
    //("mode is ",cmd.mode)
    
    // check that the pid field is valid (or empty)
    if let pid = pidField.text as String? {
        let pidtrim = pid.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (pidtrim=="") {
            // this is ok, it's optional
        } else if let pidInt = Int(pidtrim,radix:16) as NSInteger? {
            cmd.pid = pidInt
        } else {
            lastReq.text = "Invalid command : pid should be hex number (with no leading 0x)"
            return
        }
    } else {
    }
    if cmd.pid==nil {
        
    } else {

    }
    
    
    
    //TODO: add payload in diag request
    
    if let mload = ploadField.text as String? {
        let mloadtrim = mload.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if mloadtrim=="" {
            // its optional
        }
        if mloadtrim.characters.count%2==0 { //payload must be even length

            let appendedStr = "0x" + mloadtrim
            
            cmd.payload = appendedStr as NSString
        }
    } else {
        lastReq.text = "Invalid command : payload should be even length"
        return
    }
    
    // Get the Unix timestamp
    let timestamp = NSDate().timeIntervalSince1970
    cmd.timestamp = NSInteger(timestamp)
    
    
    // send the diag request
    vm.sendDiagReq(cmd)
    
    // update the last request sent label
    lastReq.text = "bus:"+String(cmd.bus)+" id:0x"+idField.text!+" mode:0x"+modeField.text!+"timestamp"+String(timestamp)
    if cmd.pid != nil {
        lastReq.text = lastReq.text!+" pid:0x"+pidField.text!
    }
    if !cmd.payload.isEqual(to: "") {
        lastReq.text = lastReq.text!+" payload:"+ploadField.text!
        requestBtn.isEnabled = false
    }
  }

}

