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
    //Payload hex 8 boxes text field outlet
   // @IBOutlet weak var dataField: UITextField!
    @IBOutlet weak var dataField1: UITextField!
    @IBOutlet weak var dataField2: UITextField!
    @IBOutlet weak var dataField3: UITextField!
    @IBOutlet weak var dataField4: UITextField!
    @IBOutlet weak var dataField5: UITextField!
    @IBOutlet weak var dataField6: UITextField!
    @IBOutlet weak var dataField7: UITextField!
    @IBOutlet weak var dataField8: UITextField!

    @IBOutlet weak var lastReq: UILabel!
    
    var payloadhex:String!
    
    var vm: VehicleManager!
    var bm: BluetoothManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // grab VM instance
        vm = VehicleManager.sharedInstance
        bm = BluetoothManager.sharedInstance
        
        // set default CAN target
        vm.setCanDefaultTarget(self, action: SendCanViewController.default_sendcan_rsp)
        
        self.dataField1.delegate = self
        self.dataField2.delegate = self
        self.dataField3.delegate = self
        self.dataField4.delegate = self
        self.dataField5.delegate = self
        self.dataField6.delegate = self
        self.dataField7.delegate = self
        self.dataField8.delegate = self
        
        idField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        dataField1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        dataField2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        dataField3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        dataField4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        dataField5.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        dataField6.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        dataField7.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        dataField8.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
    
    }
    func default_sendcan_rsp(_ rsp:NSDictionary) {
        // extract the CAN message
        let vr = rsp.object(forKey: "vehiclemessage") as! VehicleCanResponse
        print(rsp)
        // create CAN key from measurement message
        let key = String(format:"%x-%x",vr.bus,vr.id)
        let val = "0x"+(vr.data as String)
        print(key)
        print(val)
        
        // save the CAN key and can message in the dictionary
        //canDict.setObject(vr, forKey:key as NSCopying)
        
        // update the table
        DispatchQueue.main.async {
            //self.canTable.reloadData()
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func textFieldDidChange(textField: UITextField){
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if  text?.count == 2 {
            switch textField{
            case dataField1:
                dataField2.becomeFirstResponder()
            case dataField2:
                dataField3.becomeFirstResponder()
            case dataField3:
                dataField4.becomeFirstResponder()
            case dataField4:
                dataField5.becomeFirstResponder()
            case dataField5:
                dataField6.becomeFirstResponder()
            case dataField6:
                dataField7.becomeFirstResponder()
            case dataField7:
                dataField8.becomeFirstResponder()
            case dataField8:
                dataField8.resignFirstResponder()
            default:
                break
            }
        }
        if  text!.count > 2 {
           
            switch textField{
            case dataField1:
                checkMaxLength(textField: dataField1 , maxLength: 2)
            case dataField2:
                checkMaxLength(textField: dataField2 , maxLength: 2)
            case dataField3:
                checkMaxLength(textField: dataField3 , maxLength: 2)
            case dataField4:
                checkMaxLength(textField: dataField4 , maxLength: 2)
            case dataField5:
                checkMaxLength(textField: dataField5 , maxLength: 2)
            case dataField6:
                checkMaxLength(textField: dataField6 , maxLength: 2)
            case dataField7:
                checkMaxLength(textField: dataField7 , maxLength: 2)
            case dataField8:
                checkMaxLength(textField: dataField8 , maxLength: 2)
            default:
                break
            }
        }
        if  text!.count > 3 {
            checkMaxLength(textField: idField , maxLength: 3)
        }
        else{

        }
        
    }
    private func checkMaxLength(textField: UITextField!, maxLength: Int) {
        if (textField.text!.count > maxLength) {
            textField.deleteBackward()
        }
    }
    // text view delegate to clear keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    func  checkPayloadEmptyField() -> Bool {
        if ((dataField1.text != "") && (dataField2.text != "") && (dataField3.text != "") && (dataField4.text != "") &&
            (dataField5.text != "") && (dataField6.text != "") && (dataField7.text != "") && (dataField8.text != "")) { 
          let str = dataField1.text! + dataField2.text! +  dataField3.text! + dataField4.text!
          let str1 = dataField5.text! + dataField6.text! + dataField7.text! + dataField8.text!
          payloadhex = str + str1
         print (payloadhex as Any)
            return true
      }else{
          let alertController = UIAlertController(title: "", message:
              "Please enter 2 charecter data for all the field ", preferredStyle: UIAlertController.Style.alert)
          alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
          self.present(alertController, animated: true, completion: nil)
            return false
      }
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
        
            if( !checkPayloadEmptyField() ){
                return
            }
        
        if let payld = payloadhex  {              //dataField.text as String?
            let payldtrim = payld.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if payldtrim=="" {
                lastReq.text = "Invalid command : need a payload"
                return
            }
            cmd.data = payloadhex! as NSString                //dataField.text as String?
            if (cmd.data.length % 2) == 1 {
                cmd.data = "0" + payloadhex as NSString      //dataField.text! as NSString
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
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return (string.containsValidCharacter)
    }

}
  
extension String {

var containsValidCharacter: Bool {
    guard self != "" else { return true }
    let hexSet = CharacterSet(charactersIn: "1234567890ABCDEFabcdef")
    let newSet = CharacterSet(charactersIn: self)
    return hexSet.isSuperset(of: newSet)
  }
}
