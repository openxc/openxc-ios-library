//
//  SendCanViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework

class SendCanViewController: UIViewController, UITextFieldDelegate {

  // UI outlets
  @IBOutlet weak var bussel: UISegmentedControl!
  @IBOutlet weak var idField: UITextField!
  @IBOutlet weak var dataField: UITextField!
  
  @IBOutlet weak var lastReq: UILabel!

  var vm: VehicleManager!
    var bm: BluetoothManager!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    // grab VM instance
    vm = VehicleManager.sharedInstance
    bm = BluetoothManager.sharedInstance
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  
  // text view delegate to clear keyboard
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder();
    return true;
  }
    override func viewDidAppear(_ animated: Bool) {
        if(!bm.isBleConnected){
            
            AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMSG, withMessage:errorMsgBLE)
        }
    }
  
  // CAN send button hit
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
    
    // create an empty CAN request
    let cmd = VehicleCanRequest()
    
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
        cmd.id = midInt
      } else {
        lastReq.text = "Invalid command : message_id should be hex number (with no leading 0x)"
        return
      }
    } else {
      lastReq.text = "Invalid command : need a message_id"
      return
    }
   
    // check that the payload field is valid
    if let payld = dataField.text as String? {
      let payldtrim = payld.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      if payldtrim=="" {
        lastReq.text = "Invalid command : need a payload"
        return
      }
      if (Int(payldtrim,radix:16) as NSInteger?) != nil {
        cmd.data = dataField.text! as NSString
        if (cmd.data.length % 2) == 1 {
          cmd.data = "0" + dataField.text! as NSString
        }
      } else {
        lastReq.text = "Invalid command : payload should be hex number (with no leading 0x)"
        return
      }
    } else {
      lastReq.text = "Invalid command : need a payload"
      return
    }
   
    
    // send the CAN request
    vm.sendCanReq(cmd)
    
    // update the last request sent label
    lastReq.text = "bus:"+String(cmd.bus)+" id:0x"+idField.text!+" payload:0x"+String(cmd.data)
    
  }

  
  

}

