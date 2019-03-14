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
    
    // the VM
    var vm: VehicleManager!
    var bm: BluetoothManager!
    var cm: Command!
    var ObjectDic : NSMutableDictionary = NSMutableDictionary()
    var dashDict: NSMutableDictionary!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var responseLab: UILabel!
    
    @IBOutlet weak var busSeg: UISegmentedControl!
    @IBOutlet weak var enabSeg: UISegmentedControl!
    @IBOutlet weak var bypassSeg: UISegmentedControl!
    @IBOutlet weak var pFormatSeg: UISegmentedControl!
    
    @IBOutlet weak var busLabel: UILabel!
    @IBOutlet weak var enabledLabel: UILabel!
    @IBOutlet weak var bypassLabel: UILabel!
    @IBOutlet weak var formatLabel: UILabel!
    
    @IBOutlet weak var sendCmndButton: UIButton!
    
    @IBOutlet weak var acitivityInd: UIActivityIndicatorView!
    @IBOutlet weak var customCommandTF : UITextField!
    
    let commands = ["Version","Device Id","Passthrough CAN Mode","Acceptance Filter Bypass","Payload Format", "Platform", "RTC Config", "SD Card Status","Custom Command"]
    
    var versionResp: String!
    var deviceIdResp: String!
    var passthroughResp: String!
    var accFilterBypassResp: String!
    var payloadFormatResp: String!
    var platformResp: String!
    var rtcConfigResp: String!
    var sdCardResp: String!
    var customCommandResp: String!
    var isJsonFormat:Bool!
    
    var selectedRowInPicker: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        hideAll()
        customCommandTF.delegate = self
        acitivityInd.center = self.view.center
        acitivityInd.hidesWhenStopped = true
        acitivityInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        acitivityInd.isHidden = true

        // grab VM instance
        vm = VehicleManager.sharedInstance
        bm = BluetoothManager.sharedInstance
        cm = Command.sharedInstance
        // vm.setCommandDefaultTarget(self, action: CommandsViewController.handle_cmd_response)
        vm.setCommandDefaultTarget(self, action: CommandsViewController.handle_cmd_response)
        //vm.cmdObj?.setCommandDefaultTarget(self, action: CommandsViewController.handle_cmd_response)
        
        selectedRowInPicker = pickerView.selectedRow(inComponent: 0)
        
        //populateCommandResponseLabel(rowNum: selectedRowInPicker)
        
        // busSeg.addTarget(self, action: #selector(busSegmentedControlValueChanged), for: .valueChanged)
        // enabSeg.addTarget(self, action: #selector(enabSegmentedControlValueChanged), for: .valueChanged)
        //bypassSeg.addTarget(self, action: #selector(bypassSegmentedControlValueChanged), for: .valueChanged)
        // pFormatSeg.addTarget(self, action: #selector(formatSegmentedControlValueChanged), for: .valueChanged)
        
         isJsonFormat = vm.jsonMode
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!bm.isBleConnected){
            
            AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMSG, withMessage:errorMsgBLE)
            
        }
    }
    // MARK: Commands Function
    
    @IBAction func sendCmnd() {
        
        let sRow = pickerView.selectedRow(inComponent: 0)
        
        if(bm.isBleConnected){
            
            if (sRow == 8 ){
                
                if !vm.jsonMode{
                    AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMSG, withMessage: errorMsgcustomCommand)
                    return
                }
                if(customCommandTF.text == nil||customCommandTF.text == ""){
                    AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMSG, withMessage: errorMsgforText)
                    return
                }
                let str = customCommandTF.text!
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
                    AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMSG, withMessage: errorMsgCustomCommand)
                }
                
            }else{
                self.sendCommandWithValue(sRow: sRow)
            }
            
        }else{
            
            AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMSG, withMessage: errorMsgBLE)
        }
        
    }
    func validJson(strValue:String) -> Bool {
        
        if (JSONSerialization.isValidJSONObject(ObjectDic)) {
            // print("Valid Json")
            return true
        } else {
            // print("InValid Json")
            return false
        }
        
    }
    func createJSON() -> String{
        
        let jsonData = try? JSONSerialization.data(withJSONObject: ObjectDic, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        print(jsonString as Any)
        return jsonString!
        
    }
    func convertDict(cleanedstring:String){
        let searchCharacter: Character = ","
        let searchCharacter1: Character = ":"
        if cleanedstring.lowercased().characters.contains(searchCharacter) {
            let fullNameArr = cleanedstring.components(separatedBy: ",")
            for  dataValue in fullNameArr{
                if dataValue.lowercased().characters.contains(searchCharacter1) {
                    let badchar = CharacterSet(charactersIn: "\"{}[]")
                    let cleanedstring = dataValue.components(separatedBy: badchar).joined()
                    let newString3 = cleanedstring.replacingOccurrences(of: "\"", with: "")
                    let fullNameArr2 = newString3.components(separatedBy: ":")
                    
                    ObjectDic[fullNameArr2[0]] = fullNameArr2[1]
                }
            }
            
            print(ObjectDic)
        }else{
            let fullNameArr2 = cleanedstring.components(separatedBy: ":")
            ObjectDic[fullNameArr2[0]] = fullNameArr2[1]
            print(ObjectDic)
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
            //responseLab.text = ""
           
            vcm.command = .version
            self.cm.sendCommand(vcm)
            // activity indicator
            
            showActivityIndicator()
            break
        case 1:
            //responseLab.text = ""
            //let cm = VehicleCommandRequest()
            vcm.command = .device_id
            self.cm.sendCommand(vcm)
            // activity indicator
            
            showActivityIndicator()
            break
        case 2:

            
            //let cm = VehicleCommandRequest()
            
            // look at segmented control for bus
            vcm.bus = busSeg.selectedSegmentIndex + 1
            
            if enabSeg.selectedSegmentIndex==0 {
                vcm.enabled = true
            } else {
                vcm.enabled = false
            }
            
            vcm.command = .passthrough
            self.cm.sendCommand(vcm)
            // activity indicator
            
            showActivityIndicator()
            
            break
        case 3:
            
            //let cm = VehicleCommandRequest()
            // look at segmented control for bus
            vcm.bus = busSeg.selectedSegmentIndex + 1
            if bypassSeg.selectedSegmentIndex==0 {
                vcm.bypass = true
            } else {
                vcm.bypass = false
            }

            vcm.command = .af_bypass
            self.cm.sendCommand(vcm)
            showActivityIndicator()
            break
        case 4:
            
            //let cm = VehicleCommandRequest()
            
            if pFormatSeg.selectedSegmentIndex==0 {
                vcm.format = "json"
            } else {
                vcm.format = "protobuf"
            }
            vcm.command = .payload_format
            if !vm.jsonMode && pFormatSeg.selectedSegmentIndex==0{
            self.cm.sendCommand(vcm)
            showActivityIndicator()
            }
            if vm.jsonMode && pFormatSeg.selectedSegmentIndex==1{
                self.cm.sendCommand(vcm)
                showActivityIndicator()
            }
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
            vcm.command = .custom_command
            self.cm.sendCommand(vcm)
            showActivityIndicator()
            
            break
        default:
            break
        }
    }
    // this function handles all command responses
    // this function handles all command responses
    func handle_cmd_response(_ rsp:NSDictionary) {
        if UserDefaults.standard.bool(forKey: "uploadTaraceOn") {
            self.sendTraceURLData(rsp: rsp)
        }
        // extract the command response message
        let cr = rsp.object(forKey: "vehiclemessage") as! VehicleCommandResponse
        
        // update the UI depending on the command type- version,device_id works for JSON mode, not in protobuf - TODO
        
        if cr.command_response.isEqual(to: "version") || cr.command_response.isEqual(to: ".version") {
            versionResp = cr.message as String
        }
        if cr.command_response.isEqual(to: "device_id") || cr.command_response.isEqual(to: ".deviceid"){
            deviceIdResp = cr.message as String
        }
        
        if cr.command_response.isEqual(to: "passthrough") || cr.command_response.isEqual(to: ".passthrough"){
            passthroughResp = String(cr.status)
        }
        
        if cr.command_response.isEqual(to: "af_bypass") || cr.command_response.isEqual(to: ".acceptancefilterbypass") {
            accFilterBypassResp = String(cr.status)
        }
        
        if cr.command_response.isEqual(to: "payload_format") || cr.command_response.isEqual(to: ".payloadformat") {
            if(cr.status){
            if !vm.jsonMode && !isJsonFormat{
            vm.setProtobufMode(false)
            UserDefaults.standard.set(false, forKey:"protobufOn")
            }
            if vm.jsonMode && isJsonFormat{
                vm.setProtobufMode(true)
                UserDefaults.standard.set(true, forKey:"protobufOn")
                 payloadFormatResp = String(cr.status)
            }
            }
            payloadFormatResp = String(cr.status)
            isJsonFormat = vm.jsonMode
        }
        if cr.command_response.isEqual(to: "platform") || cr.command_response.isEqual(to: ".platform"){
            platformResp = cr.message as String
        }
        if cr.command_response.isEqual(to: "rtc_configuration") || cr.command_response.isEqual(to: ".rtcconfiguration") {
            rtcConfigResp = String(cr.status)
        }
        if cr.command_response.isEqual(to: "sd_mount_status") || cr.command_response.isEqual(to: ".sdmountstatus"){
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
        
        rowTitle = NSAttributedString(string: commands[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        return rowTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedRowInPicker = row
        populateCommandResponseLabel(rowNum: row)
        responseLab.text = "---"
        if (row == 8){
            customCommandTF.isHidden = false
            
        }else{
            customCommandTF.isHidden = true
            
        }
        
    }
    
    // MARK: UI Function
    
    func populateCommandResponseLabel(rowNum: Int) {
        hideAll()
        hideActivityIndicator()
        
        switch rowNum {
        case 0:
            sendCmndButton.isHidden = false
            responseLab.text = versionResp
            break
        case 1:
            sendCmndButton.isHidden = false
            responseLab.text = deviceIdResp
            break
        case 2:
            sendCmndButton.isHidden = false
            responseLab.text = passthroughResp
            busLabel.isHidden = false
            busSeg.isHidden = false
            enabledLabel.isHidden = false
            enabSeg.isHidden = false
            break
        case 3:
            sendCmndButton.isHidden = false
            responseLab.text = accFilterBypassResp
            busLabel.isHidden = false
            busSeg.isHidden = false
            bypassLabel.isHidden = false
            bypassSeg.isHidden = false
            break
        case 4:
            sendCmndButton.isHidden = false
            responseLab.text = payloadFormatResp
            formatLabel.isHidden = false
            pFormatSeg.isHidden = false
            break
        case 5:
            sendCmndButton.isHidden = false
            responseLab.text = platformResp
            break
        case 6:
            sendCmndButton.isHidden = false
            responseLab.text = rtcConfigResp
            break
        case 7:
            sendCmndButton.isHidden = false
            responseLab.text = sdCardResp
            break
        case 8:
            sendCmndButton.isHidden = false
            responseLab.text = customCommandResp
            break
        default:
            sendCmndButton.isHidden = true
            responseLab.text = versionResp
        }
    }
    
    func hideAll() {
        busSeg.isHidden = true
        enabSeg.isHidden = true
        bypassSeg.isHidden = true
        pFormatSeg.isHidden = true
        busLabel.isHidden = true
        enabledLabel.isHidden = true
        bypassLabel.isHidden = true
        formatLabel.isHidden = true
    }
    
    func showActivityIndicator() {
        acitivityInd.startAnimating()
        self.view.alpha = 0.5
        self.view.isUserInteractionEnabled = false
        
    }
    func hideActivityIndicator() {
        acitivityInd.stopAnimating()
        self.view.alpha = 1.0
        self.view.isUserInteractionEnabled = true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        customCommandTF.resignFirstResponder()
        
        return true
    }
}

