//
//  DataSourceController.swift
//  openXCenabler
//
//  Created by Ranjan, Kumar sahu (K.) on 22/03/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import UIKit
import openXCiOSFramework
import CoreLocation

class DataSourceController: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate {
    
    
    @IBOutlet var popupView: UIView!
    
    @IBOutlet weak var bluetoothButton: UIButton!
    @IBOutlet weak var networkButton: UIButton!
    @IBOutlet weak var traceFileButton: UIButton!
    @IBOutlet weak var noneButton: UIButton!
    @IBOutlet weak var acitivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //Tracefile play back switch and textfield
    @IBOutlet weak var playSwitch: UISwitch!
    @IBOutlet weak var TraceFilePlayNameField: UITextField!
    
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var bleAutoConnectSwitch: UISwitch!
    @IBOutlet weak var protobufSwitch: UISwitch!
    @IBOutlet weak var sensorSwitch: UISwitch!
    @IBOutlet weak var disableTraceFilePlayLoopSwitch: UISwitch!
    
    //ranjan added code for Network data
    @IBOutlet weak var throughPutSwitch: UISwitch!
    @IBOutlet weak var networkDataSwitch: UISwitch!
    @IBOutlet weak var networkDataHostField: UITextField!
    @IBOutlet weak var networkDataPortField: UITextField!
    
    
    var interfaceValue:String!
    var locationManager = CLLocationManager()
    
    //Singleton Instance
    var NM : NetworkDataManager!
    var vm : VehicleManager!
    var tfm: TraceFileManager!
    var bm: BluetoothManager!
    // timer for UI counter updates
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NM = NetworkDataManager.sharedInstance
        vm = VehicleManager.sharedInstance
        tfm = TraceFileManager.sharedInstance
        bm = BluetoothManager.sharedInstance
        // Do any additional setup after loading the view.
        popupView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        disableTraceFilePlayLoopSwitch.isUserInteractionEnabled = false
        
        vm.setCommandDefaultTarget(self, action: DataSourceController.handle_cmd_response)
        //ranjan added code for Network data
        // watch for changes to network file output file name field
        networkDataHostField.addTarget(self, action: #selector(networkDataFieldDidChange), for:UIControl.Event.editingChanged)
        networkDataPortField.addTarget(self, action: #selector(networkPortFieldDidChange), for:UIControl.Event.editingChanged)
        //networkDataHost.isHidden = true
        
        // watch for changes to trace file input file name field
        TraceFilePlayNameField.addTarget(self, action: #selector(playFieldDidChange), for: UIControl.Event.editingChanged)
        // playname.isHidden = true
        
        
        // check saved value of trace input switch
        let locationIsOn = UserDefaults.standard.bool(forKey: "locationOn")
        // update UI if necessary
        if locationIsOn == true {
            locationSwitch.setOn(true, animated:false)
            //playname.isHidden = false
        }
        // check saved value of autoconnect switcg
        let autoOn = UserDefaults.standard.bool(forKey: "autoConnectOn")
        // update UI if necessary
        if autoOn == true {
            bleAutoConnectSwitch.setOn(true, animated:false)
        }
        // check saved value of sensor switch
        let sensorOn = UserDefaults.standard.bool(forKey: "sensorsOn")
        // update UI if necessary
        if sensorOn == true {
            sensorSwitch.setOn(true, animated:false)
        }
        // check saved value of throughput switch
        let throughputOn = UserDefaults.standard.bool(forKey: "throughputOn")
        // update UI if necessary
        if throughputOn == true {
            throughPutSwitch.setOn(true, animated:false)
        }// check saved value of disable trace switch
        let disableTraceOn = UserDefaults.standard.bool(forKey: "disableTraceLoopOn")
        // update UI if necessary
        if disableTraceOn == true {
            disableTraceFilePlayLoopSwitch.setOn(true, animated:false)
        }
        // check saved value of protobuf switch
        let protobufOn = UserDefaults.standard.bool(forKey: "protobufOn")
        // update UI if necessary
        if protobufOn == true {
            protobufSwitch.setOn(true, animated:false)
        }
        let vehicleInterface = (UserDefaults.standard.value(forKey: "vehicleInterface") as? String)
        
        if  vehicleInterface == "Bluetooth" {
            titleLabel.text = vehicleInterface
            interfaceValue = vehicleInterface
            
        }
        else if  vehicleInterface == "Network" {
            if let hostName = (UserDefaults.standard.value(forKey: "networkHostName")  as? String){
                networkDataHostField.text = hostName
                networkDataPortField.text = (UserDefaults.standard.value(forKey: "networkPortName")  as! String)
                
            }
            interfaceValue = vehicleInterface
            
            
        }
            
        else if vehicleInterface == preRecordTrace {
            if let tracefile = (UserDefaults.standard.value(forKey: "traceInputFilename")  as? String){
                TraceFilePlayNameField.text = tracefile
            }
            disableTraceFilePlayLoopSwitch.isUserInteractionEnabled = true
            interfaceValue = vehicleInterface
        }
        else if vehicleInterface ==  "None"{
            interfaceValue = "None"
            
        }else{
            titleLabel.text = "Bluetooth"
            interfaceValue = "Bluetooth"
        }
        self.setValueVehicleInterface()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Dismiss button main view Action
    @IBAction func dismissView(_ sender: AnyObject) {
        
        self.dismiss(animated: true, completion: nil)
    }
    //Vehicle interface button main view Action
    @IBAction func vehicleInterfaceBtn(_ sender: AnyObject) {
        
        networkDataHostField.resignFirstResponder()
        networkDataPortField.resignFirstResponder()
        TraceFilePlayNameField.resignFirstResponder()
        
        TraceFilePlayNameField.backgroundColor = UIColor.white
        networkDataHostField.backgroundColor = UIColor.white
        networkDataPortField.backgroundColor = UIColor.white
        
        popupView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        self.view.addSubview(popupView)
        if let vechileInterface = UserDefaults.standard.value(forKey: "vehicleInterface") as? NSString {
            titleLabel.text = vechileInterface as String
            interfaceValue = vechileInterface as String
            self.setValueForRadioBtn()
        }
    }
    //Cancel button on pop up view Action
    @IBAction func cancelBtn(_ sender: AnyObject) {
        
        popupView.removeFromSuperview()
        self.setValueVehicleInterface()
    }
    //Radio buttons on pop up view Action
    @IBAction func bluetoothBtnAction(_ sender: Any) {
        
        bluetoothButton.isSelected = true
        networkButton.isSelected = false
        traceFileButton.isSelected = false
        noneButton.isSelected = false
        interfaceValue = "Bluetooth"
        popupView.removeFromSuperview()
        self.setValueVehicleInterface()
    }
    @IBAction func networkBtnAction(_ sender: Any) {
        
        bluetoothButton.isSelected = false
        networkButton.isSelected = true
        traceFileButton.isSelected = false
        noneButton.isSelected = false
        interfaceValue = "Network"
        popupView.removeFromSuperview()
        self.setValueVehicleInterface()
    }
    @IBAction func trscefileBtnAction(_ sender: Any) {
        let traceSinkOn = UserDefaults.standard.bool(forKey: "traceOutputOn")
        if (!traceSinkOn){
        bluetoothButton.isSelected = false
        networkButton.isSelected = false
        traceFileButton.isSelected = true
        noneButton.isSelected = false
        //declare in utility file "Pre-recorded Tracefile"
        interfaceValue = preRecordTrace
        popupView.removeFromSuperview()
        self.setValueVehicleInterface()
        }else{
            let alertController = UIAlertController(title: "", message:
                "Please stop recording to trace file", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    @IBAction func noneBtnAction(_ sender: Any) {
        
        bluetoothButton.isSelected = false
        networkButton.isSelected = false
        traceFileButton.isSelected = false
        noneButton.isSelected = true
        interfaceValue = "None"
        popupView.removeFromSuperview()
        self.setValueVehicleInterface()
    }
    func setValueForRadioBtn(){
        if  (interfaceValue == "Bluetooth") {
            bluetoothButton.isSelected = true
            networkButton.isSelected = false
            traceFileButton.isSelected = false
            noneButton.isSelected = false
        }else if  (interfaceValue == preRecordTrace) {
            bluetoothButton.isSelected = false
            networkButton.isSelected = false
            traceFileButton.isSelected = true
            noneButton.isSelected = false
            
        }else if  (interfaceValue == "Network") {
            bluetoothButton.isSelected = false
            networkButton.isSelected = true
            traceFileButton.isSelected = false
            noneButton.isSelected = false
            
        }else  {
            bluetoothButton.isSelected = false
            networkButton.isSelected = false
            traceFileButton.isSelected = false
            noneButton.isSelected = true
            
        }
    }
    func setValueVehicleInterface(){
        disableTraceFilePlayLoopSwitch.isUserInteractionEnabled = false
        if  (interfaceValue == "None") {
            
            TraceFilePlayNameField.isUserInteractionEnabled = false
            networkDataHostField.isUserInteractionEnabled = false
            networkDataPortField.isUserInteractionEnabled = false
            
            TraceFilePlayNameField.backgroundColor = UIColor.lightGray
            networkDataHostField.backgroundColor = UIColor.lightGray
            networkDataPortField.backgroundColor = UIColor.lightGray
            
            UserDefaults.standard.set(interfaceValue, forKey:"vehicleInterface")
            titleLabel.text = interfaceValue
            
            tfm.disableTraceFileSource()
            NM.disconnectConnection()
            if (bm.isBleConnected) {
                bm.disconnect()
            }
            
            networkDataPortField.text = ""
            networkDataHostField.text = ""
            TraceFilePlayNameField.text = ""
            
        }
        else if  (interfaceValue == preRecordTrace) {
            TraceFilePlayNameField.isUserInteractionEnabled = true
            
            networkDataHostField.backgroundColor = UIColor.lightGray
            networkDataPortField.backgroundColor = UIColor.lightGray
            
            networkDataHostField.isUserInteractionEnabled = false
            networkDataPortField.isUserInteractionEnabled = false
            if let name = UserDefaults.standard.value(forKey: "traceInputFilename") as? NSString {
                TraceFilePlayNameField.text = name as String
            }
            UserDefaults.standard.set(interfaceValue, forKey:"vehicleInterface")
            titleLabel.text = interfaceValue
            NM.disconnectConnection()
            if (bm.isBleConnected) {
                bm.disconnect()
            }
            networkDataPortField.text = ""
            networkDataHostField.text = ""
            disableTraceFilePlayLoopSwitch.isUserInteractionEnabled = true
        }
        else if  (interfaceValue == "Network") {
            TraceFilePlayNameField.isUserInteractionEnabled = false
            TraceFilePlayNameField.backgroundColor = UIColor.lightGray
            networkDataHostField.isUserInteractionEnabled = true
            networkDataPortField.isUserInteractionEnabled = true
            UserDefaults.standard.set(interfaceValue, forKey:"vehicleInterface")
            titleLabel.text = interfaceValue
            if let name = (UserDefaults.standard.value(forKey: "networkHostName") as? String) {
                networkDataHostField.text = name
                networkDataPortField.text = (UserDefaults.standard.value(forKey: "networkPortName")  as! String)
            }
            if (bm.isBleConnected) {
                bm.disconnect()
            }
            tfm.disableTraceFileSource()
            TraceFilePlayNameField.text = ""
        }
        else  {
            TraceFilePlayNameField.isUserInteractionEnabled = false
            networkDataHostField.isUserInteractionEnabled = false
            networkDataPortField.isUserInteractionEnabled = false
            
            TraceFilePlayNameField.backgroundColor = UIColor.lightGray
            networkDataHostField.backgroundColor = UIColor.lightGray
            networkDataPortField.backgroundColor = UIColor.lightGray
            if  (interfaceValue == "None") {
                titleLabel.text = interfaceValue
                UserDefaults.standard.set("None", forKey:"vehicleInterface")
            }else{
                titleLabel.text = interfaceValue
                UserDefaults.standard.set("Bluetooth", forKey:"vehicleInterface")
            }
            
            tfm.disableTraceFileSource()
            NM.disconnectConnection()
            
            networkDataPortField.text = ""
            networkDataHostField.text = ""
            TraceFilePlayNameField.text = ""
            
        }
        
    }
    
    // the trace output enabled switch changed, save it's new value
    // and show or hide the text field for filename accordingly
    @IBAction func locationChange(_ sender: UISwitch) {
        
        UserDefaults.standard.set(sender.isOn, forKey:"locationOn")
        
    }
    // autoconnect switch changed, save it's value
    @IBAction func autoChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"autoConnectOn")
        if sender.isOn{
            bm.setAutoconnect(true)
        }
    }
    
    // include sensor switch changed, save it's value
    @IBAction func sensorChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"sensorsOn")
    }
    // throughput mode switch changed, save it's value
    @IBAction func throughputswitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"throughputOn")
    }
    // disableTraceLoop mode switch changed, save it's value
    @IBAction func disableTraceLoop(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"disableTraceLoopOn")
        if(!sender.isOn){
            tfm.traceFileRestart()
        }
    }
    // protbuf mode switch changed, save it's value
    @IBAction func protoChange(_ sender: UISwitch) {
        if sender.isOn {
            self.payloadFormatCommand(platformFormat:"protobuf")
        }else{
            self.payloadFormatCommand(platformFormat:"json")
        }
        UserDefaults.standard.set(sender.isOn, forKey:"protobufOn")
    }
    
    func payloadFormatCommand(platformFormat:NSString) {
        if bm.isBleConnected{
            let cm = VehicleCommandRequest()
            if (platformFormat == "protobuf" ){
                cm.format = "protobuf"
            }
            else{
                cm.format = "json"
            }
            
            cm.command = .payload_format
            self.vm.sendCommand(cm)
            //showActivityIndicator()
            
        }
    }
    func showActivityIndicator() {
        //acitivityInd.startAnimating()
        self.view.alpha = 0.5
        
        
    }
    func hideActivityIndicator() {
        //acitivityInd.stopAnimating()
        self.view.alpha = 1.0
        
        
    }
    // MARK: UI Function
    
    func handle_cmd_response(_ rsp:NSDictionary) {
        // extract the command response message
        let cr = rsp.object(forKey: "vehiclemessage") as! VehicleCommandResponse
        
        
        if(cr.status){
            if !vm.jsonMode {
                vm.setProtobufMode(false)
                UserDefaults.standard.set(false, forKey:"protobufOn")
                return
            }
            if vm.jsonMode {
                vm.setProtobufMode(true)
                UserDefaults.standard.set(true, forKey:"protobufOn")
                return
            }
        }
    }
    // text view delegate to clear keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 101{
            textField.resignFirstResponder()
            UserDefaults.standard.set(TraceFilePlayNameField.text, forKey:"traceInputFilename")
           let value = tfm.enableTraceFileSource(TraceFilePlayNameField.text! as NSString)
            print(value)
        }
        if textField.tag == 102{
            if (textField.text != ""){
                networkDataPortField.becomeFirstResponder()
            }else{
                
                let alertController = UIAlertController(title: "", message:
                    "Please enter valid host name", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        if textField.tag == 103{
            if (textField.text != ""){
                self.networkDataFetch(hostName: networkDataHostField.text!,PortName: networkDataPortField.text!)
                UserDefaults.standard.set(networkDataHostField.text!, forKey:"networkHostName")
                UserDefaults.standard.set(networkDataPortField.text!, forKey:"networkPortName")
                textField.resignFirstResponder();
            }else{
                let alertController = UIAlertController(title: "", message:
                    "Please enter valid port number", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
        return true;
    }
    //ranjan added code for Network data
    func networkDataFetch(hostName:String,PortName:String)  {
        let port  = Int(PortName)
        if(hostName != "" && PortName != ""){
            NetworkDataManager.sharedInstance.connect(ip:hostName, portvalue: port!, completionHandler: { (success) in
                print(success)
                if(success){
                    UserDefaults.standard.set(hostName, forKey:"networkHostName")
                    UserDefaults.standard.set(PortName, forKey:"networkPortName")
                    
                }else{
                    let alertController = UIAlertController(title: "", message:
                        "error ocured in connection", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    UserDefaults.standard.set(nil, forKey:"networkHostName")
                    UserDefaults.standard.set(nil, forKey:"networkPortName")
                }
            })
        }
        
        
    }

    // trace file output file name changed, save it in nsuserdefaults
    @objc func networkDataFieldDidChange(_ textField: UITextField) {
        //UserDefaults.standard.set(textField.text, forKey:"networkAdress")
    }
    @objc func networkPortFieldDidChange(_ textField: UITextField) {
        //UserDefaults.standard.set(textField.text, forKey:"networkAdress")
    }
    // trace file input file name changed, save it in nsuserdefaults
    @objc func playFieldDidChange(_ textField: UITextField) {
        UserDefaults.standard.set(textField.text, forKey:"traceInputFilename")
    }
    
    
    func keyboardWillShow() {
        if view.frame.origin.y == 0{
            self.view.frame.origin.y -= 120
        }
    }
    
    func keyboardWillHide() {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y += 120
        }
    }
}
