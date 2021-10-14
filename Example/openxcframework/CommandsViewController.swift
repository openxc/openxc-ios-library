//
//  CommandsViewController.swift
//  openXCenabler
//
//  Created by Kanishka, Vedi (V.) on 27/04/17.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework


class CommandsViewController:UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    
    // the VM instance
    var vm: VehicleManager!
    var bm: BluetoothManager!
    var cm: Command!
    var objectDic : NSMutableDictionary = NSMutableDictionary()
    var dashDict: NSMutableDictionary!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var responseLab: UILabel!
    
    @IBOutlet weak var busSeg: UISegmentedControl!
    @IBOutlet weak var enabledSeg: UISegmentedControl!
    @IBOutlet weak var bypassSeg: UISegmentedControl!
    @IBOutlet weak var payloadFormatSeg: UISegmentedControl!
    
    @IBOutlet weak var busLabel: UILabel!
    @IBOutlet weak var enabledLabel: UILabel!
    @IBOutlet weak var bypassLabel: UILabel!
    @IBOutlet weak var formatLabel: UILabel!
    
    @IBOutlet weak var sendCommandButton: UIButton!
    
    @IBOutlet weak var acitivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var customCommandTextField : UITextField!
    
    let commands = ["Version","Device Id","Passthrough CAN Mode","Acceptance Filter Bypass","Payload Format", "Platform", "RTC Config", "SD Card Status","get_vin","Custom Command"]
    
    var versionResponse: String!
    var deviceIdResponse: String!
    var passThroughResponse: String!
    var acceptanceFilterBypassResponse: String!
    var payloadFormatResponse: String!
    var platformResponse: String!
    var rtcConfigResponse: String!
    var sdCardResp: String!
    var customCommandResp: String!
    var isJsonFormat:Bool!
    var selectedRowInPicker: Int!
    var vinResponse: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        hideAll()
        customCommandTextField.delegate = self
        acitivityIndicator.center = self.view.center
        acitivityIndicator.hidesWhenStopped = true
        acitivityIndicator.style =
            UIActivityIndicatorView.Style.whiteLarge
        acitivityIndicator.isHidden = true
        
        // grab VM instance
        vm = VehicleManager.sharedInstance
        bm = BluetoothManager.sharedInstance
        cm = Command.sharedInstance
        
        vm.setCommandDefaultTarget(self, action: CommandsViewController.handleCommandResponse)
        
        vm.setManagerCallbackTarget(self, action: CommandsViewController.managerStatusUpdates)
        selectedRowInPicker = pickerView.selectedRow(inComponent: 0)
        
        isJsonFormat = vm.jsonMode
        
        
    }
    func managerStatusUpdates(_ rsp:NSDictionary) {
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
    override func viewDidAppear(_ animated: Bool) {
        //Receive notification for the power drop
        
        if(!bm.isBleConnected){
            AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMsg, withMessage:errorMsgBLE)
        }
    }
    // MARK: Commands Function
    
    @IBAction func sendCommand() {
        
        let sRow = pickerView.selectedRow(inComponent: 0)
        
        if(bm.isBleConnected){
            
            if (sRow == 8 && !vm.jsonMode ){
  
                    AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMsg, withMessage: errorMsgCustomCommandProto)
                
                if(customCommandTextField.text == nil||customCommandTextField.text == ""){
                    AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMsg, withMessage: errorMsgText)
                    return
                }
                let str = customCommandTextField.text!
                let stringq = str.description.replacingOccurrences(of: "\"", with: "")
                self.convertToJson(string: stringq)
                let jsonString = self.createJSON()
                let value = validJson(strValue: jsonString)
                
                if value{
                    let cm1 = VehicleCommandRequest()
                    cm1.command = .custom_command
                    cm.customCommand(jsonString: jsonString)
                    showActivityIndicator()
                    
                }else{
                    AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMsg, withMessage: errorMsgCustomCommand)
                }
                
            }else
            {
                self.sendCommandWithValue(sRow: sRow)
            }
            
        }else{
            
            AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMsg, withMessage: errorMsgBLE)
        }
    }
    func validJson(strValue:String) -> Bool {
        
        if (JSONSerialization.isValidJSONObject(objectDic)) {
            // print("Valid Json")
            return true
        } else {
            // print("InValid Json")
            return false
        }
        
    }
    func createJSON() -> String{
        
        let jsonData = try? JSONSerialization.data(withJSONObject: objectDic, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        print(jsonString as Any)
        return jsonString!
        
    }
    func convertDict(cleanedstring:String){
        let searchCharacter: Character = ","
        let searchCharacter1: Character = ":"
        if cleanedstring.lowercased().contains(searchCharacter) {
            let fullNameArr = cleanedstring.components(separatedBy: ",")
            for  dataValue in fullNameArr{
                if dataValue.lowercased().contains(searchCharacter1) {
                    let badchar = CharacterSet(charactersIn: "\"{}[]")
                    let cleanedstring = dataValue.components(separatedBy: badchar).joined()
                    let newString3 = cleanedstring.replacingOccurrences(of: "\"", with: "")
                    let fullNameArr2 = newString3.components(separatedBy: ":")
                    
                    objectDic[fullNameArr2[0]] = fullNameArr2[1]
                }
            }
            
        }else{
            let fullNameArr2 = cleanedstring.components(separatedBy: ":")
            objectDic[fullNameArr2[0]] = fullNameArr2[1]
        }
    }
    func convertToJson(string:String){
        
        let trimmedString = string.trimmingCharacters(in: CharacterSet(charactersIn: "{}"))
        
        self.convertDict(cleanedstring: trimmedString)
        
    }
    func  sendCommandWithValue(sRow:NSInteger){
        let vcm = VehicleCommandRequest()
        switch sRow {
        case 0:
            vcm.command = .version
            self.cm.sendCommand(vcm)
            
            showActivityIndicator()
            break
        case 1:
            vcm.command = .device_id
            self.cm.sendCommand(vcm)
            
            showActivityIndicator()
            break
        case 2:
            
            // look at segmented control for bus
            vcm.bus = busSeg.selectedSegmentIndex + 1
            vcm.enabled = false
            if enabledSeg.selectedSegmentIndex==0 {
                vcm.enabled = true
            }
            vcm.command = .passthrough
            self.cm.sendCommand(vcm)
            showActivityIndicator()
            
            break
        case 3:
            // look at segmented control for bus
            vcm.bus = busSeg.selectedSegmentIndex + 1
            vcm.bypass = false
            if bypassSeg.selectedSegmentIndex==0 {
                vcm.bypass = true
            }
            vcm.command = .af_bypass
            self.cm.sendCommand(vcm)
            showActivityIndicator()
            break
        case 4:
            
            //let cm = VehicleCommandRequest()
            vcm.format = "protobuf"
            if payloadFormatSeg.selectedSegmentIndex==0 {
                vcm.format = "json"
            }
             self.cm.sendCommand(vcm)
            vcm.command = .payload_format
            if !vm.jsonMode && payloadFormatSeg.selectedSegmentIndex==0{
                self.cm.sendCommand(vcm)
            }
                showActivityIndicator()
            break
        case 5:
            //let cm = VehicleCommandRequest()
            vcm.command = .platform
            self.cm.sendCommand(vcm)
            showActivityIndicator()
            break
        case 6:
            //let cm = VehicleCommandRequest()
            vcm.command = .rtc_configuration
            self.cm.sendCommand(vcm)
            showActivityIndicator()
            break
        case 7:
            
            //let cm = VehicleCommandRequest()
            vcm.command = .sd_mount_status
            self.cm.sendCommand(vcm)
            showActivityIndicator()
            break
        case 8:
            
            //let cm = VehicleCommandRequest()
            vcm.command = .get_Vin
            self.cm.sendCommand(vcm)
            showActivityIndicator()
            break
            
            case 9:
            
            //let cm = VehicleCommandRequest()
                vcm.command = .custom_command
                self.cm.sendCommand(vcm)
                showActivityIndicator()
            
            break
        default:
            break
        }
    }

    // this function handles all command responses
    func handleCommandResponse(_ rsp:NSDictionary) {
        if UserDefaults.standard.bool(forKey: "uploadTaraceOn") {
            self.sendTraceURLData(rsp: rsp)
        }
        // extract the command response message
        let cr = rsp.object(forKey: "vehiclemessage") as! VehicleCommandResponse
        
        // update the UI depending on the command type- version,device_id works for JSON mode, not in protobuf - TODO
        
        if cr.command_response.isEqual(to: "version") || cr.command_response.isEqual(to: ".version") {
            versionResponse = cr.message as String
        }
       if cr.command_response.isEqual(to: "device_id") || cr.command_response.isEqual(to: ".deviceId") || cr.command_response.isEqual(to: ".deviceid"){
            deviceIdResponse = cr.message as String
        }
        
        if cr.command_response.isEqual(to: "passthrough") || cr.command_response.isEqual(to: ".passthrough"){
            passThroughResponse = String(cr.status)
        }
        
         if cr.command_response.isEqual(to: "af_bypass") || cr.command_response.isEqual(to: ".acceptancefilterbypass") {
            acceptanceFilterBypassResponse = String(cr.status)
        }
        if cr.command_response.isEqual(to: "get_vin") || cr.command_response.isEqual(to: ".get_vin") {
            vinResponse = cr.message as String
           }
        self.handleVehicleCommandResponse(cr: cr)
        
      
    }
    func handleVehicleCommandResponse(cr:VehicleCommandResponse){
        
        if cr.command_response.isEqual(to: "payload_format") || cr.command_response.isEqual(to: ".payloadformat") {
                   if(cr.status && !vm.jsonMode && !isJsonFormat){
                           vm.setProtobufMode(false)
                           UserDefaults.standard.set(false, forKey:"protobufOn")
                       
                   }else{
                       vm.setProtobufMode(true)
                       UserDefaults.standard.set(true, forKey:"protobufOn")
                   }
                   payloadFormatResponse = String(cr.status)
                   isJsonFormat = vm.jsonMode
               }
                if cr.command_response.isEqual(to: "platform") || cr.command_response.isEqual(to: ".platform"){
                   platformResponse = cr.message as String
               }
               if cr.command_response.isEqual(to: "rtc_configuration") || cr.command_response.isEqual(to: ".rtcconfiguration") {
                   rtcConfigResponse = String(cr.status)
               }
                if cr.command_response.isEqual(to: "sd_mount_status") || cr.command_response.isEqual(to: ".sdmountStatus") || cr.command_response.isEqual(to: ".sdMountStatus"){
                   sdCardResp = String(cr.status)
               }else{
                   customCommandResp = String(cr.message)
               }
               // update the label
               DispatchQueue.main.async {
                   self.populateCommandResponseLabel(rowNum: self.selectedRowInPicker)
               }
    }
    
    @objc func sendTraceURLData(rsp:NSDictionary) {
        let cr = rsp.object(forKey: "vehiclemessage") as! VehicleCommandResponse
        
        if rsp.allKeys.count > 2 {
            dashDict.setObject(cr.command_response,forKey: "command_response" as NSCopying)
            dashDict.setObject(cr.message,forKey: "message" as NSCopying)
            dashDict.setObject(cr.status,forKey: "status" as NSCopying)
        }else{
            dashDict.setObject(cr.command_response,forKey: "command_response" as NSCopying)
            dashDict.setObject(cr.status,forKey: "status" as NSCopying)
        }
        if let urlname = (UserDefaults.standard.value(forKey: "traceURLname") as? String) {
            vm.sendTraceURLData(urlName:urlname,rspdict: dashDict , isdrrsp: true)
        }
        
    }
    // MARK: Picker Delgate Function
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return commands.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var rowTitle:NSAttributedString!
        
        rowTitle = NSAttributedString(string: commands[row], attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        return rowTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedRowInPicker = row
        populateCommandResponseLabel(rowNum: row)
        responseLab.text = "---"
        if (row == 9){
            customCommandTextField.isHidden = false
            
        }else{
            customCommandTextField.isHidden = true
            
        }
        
    }
    
    // MARK: UI Function
    
    func populateCommandResponseLabel(rowNum: Int) {
        hideAll()
        hideActivityIndicator()
        
        switch rowNum {
        case 0:
            sendCommandButton.isHidden = false
            responseLab.text = versionResponse
            break
        case 1:
            sendCommandButton.isHidden = false
            responseLab.text = deviceIdResponse
            break
        case 2:
            sendCommandButton.isHidden = false
            responseLab.text = passThroughResponse
            busLabel.isHidden = false
            busSeg.isHidden = false
            enabledLabel.isHidden = false
            enabledSeg.isHidden = false
            break
        case 3:
            sendCommandButton.isHidden = false
            responseLab.text = acceptanceFilterBypassResponse
            busLabel.isHidden = false
            busSeg.isHidden = false
            bypassLabel.isHidden = false
            bypassSeg.isHidden = false
            break
        case 4:
            sendCommandButton.isHidden = false
            responseLab.text = payloadFormatResponse
            formatLabel.isHidden = false
            payloadFormatSeg.isHidden = false
            break
        case 5:
            sendCommandButton.isHidden = false
            responseLab.text = platformResponse
            break
        case 6:
            sendCommandButton.isHidden = false
            responseLab.text = rtcConfigResponse
            break
        case 7:
            sendCommandButton.isHidden = false
            responseLab.text = sdCardResp
            break
        case 8:
            sendCommandButton.isHidden = false
            responseLab.text = vinResponse
            break
        case 9:
            sendCommandButton.isHidden = false
            responseLab.text = customCommandResp
            break
        default:
            sendCommandButton.isHidden = true
            responseLab.text = versionResponse
        }
    }
    
    func hideAll() {
        busSeg.isHidden = true
        enabledSeg.isHidden = true
        bypassSeg.isHidden = true
        payloadFormatSeg.isHidden = true
        busLabel.isHidden = true
        enabledLabel.isHidden = true
        bypassLabel.isHidden = true
        formatLabel.isHidden = true
    }
    
    func showActivityIndicator() {
        acitivityIndicator.startAnimating()
        self.view.alpha = 0.5
        self.view.isUserInteractionEnabled = false
        
    }
    func hideActivityIndicator() {
        acitivityIndicator.stopAnimating()
        self.view.alpha = 1.0
        self.view.isUserInteractionEnabled = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        customCommandTextField.resignFirstResponder()
        
        return true
    }
}

