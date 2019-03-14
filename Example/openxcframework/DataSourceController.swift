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

    
    @IBOutlet var PopupView: UIView!
    
    @IBOutlet weak var bluetoothBtn: UIButton!
    @IBOutlet weak var networkBtn: UIButton!
    @IBOutlet weak var tracefileBtn: UIButton!
    @IBOutlet weak var noneBtn: UIButton!
    @IBOutlet weak var acitivityInd: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //Tracefile play back switch and textfield
    @IBOutlet weak var playswitch: UISwitch!
    @IBOutlet weak var playname: UITextField!

    @IBOutlet weak var locationswitch: UISwitch!
    @IBOutlet weak var bleAutoswitch: UISwitch!
    @IBOutlet weak var protoswitch: UISwitch!
    @IBOutlet weak var sensorswitch: UISwitch!
    
    //ranjan added code for Network data
    @IBOutlet weak var throughputswitch: UISwitch!
    @IBOutlet weak var networkDataswitch: UISwitch!
    @IBOutlet weak var networkDataHost: UITextField!
    @IBOutlet weak var networkDataPort: UITextField!
    
    
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
        PopupView.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        vm.setCommandDefaultTarget(self, action: DataSourceController.handle_cmd_response)
         //ranjan added code for Network data
         // watch for changes to network file output file name field
         networkDataHost.addTarget(self, action: #selector(networkDataFieldDidChange), for:UIControlEvents.editingChanged)
         networkDataPort.addTarget(self, action: #selector(networkPortFieldDidChange), for:UIControlEvents.editingChanged)
         //networkDataHost.isHidden = true
     
         // watch for changes to trace file input file name field
         playname.addTarget(self, action: #selector(playFieldDidChange), for: UIControlEvents.editingChanged)
        // playname.isHidden = true

        
        // check saved value of trace input switch
        let locationIsOn = UserDefaults.standard.bool(forKey: "locationOn")
        // update UI if necessary
        if locationIsOn == true {
            locationswitch.setOn(true, animated:false)
            //playname.isHidden = false
        }
        // check saved value of autoconnect switcg
        let autoOn = UserDefaults.standard.bool(forKey: "autoConnectOn")
        // update UI if necessary
        if autoOn == true {
            bleAutoswitch.setOn(true, animated:false)
        }
        // check saved value of sensor switch
        let sensorOn = UserDefaults.standard.bool(forKey: "sensorsOn")
        // update UI if necessary
        if sensorOn == true {
            sensorswitch.setOn(true, animated:false)
        }
        // check saved value of throughput switch
        let throughputOn = UserDefaults.standard.bool(forKey: "throughputOn")
        // update UI if necessary
        if throughputOn == true {
            throughputswitch.setOn(true, animated:false)
        }
        // check saved value of protobuf switch
        let protobufOn = UserDefaults.standard.bool(forKey: "protobufOn")
        // update UI if necessary
        if protobufOn == true {
            protoswitch.setOn(true, animated:false)
        }
        let vehicleInterface = (UserDefaults.standard.value(forKey: "vehicleInterface") as? String)
        
        if  vehicleInterface == "Bluetooth" {
            titleLabel.text = vehicleInterface
            interfaceValue = vehicleInterface
           
        }
        else if  vehicleInterface == "Network" {
            if let hostName = (UserDefaults.standard.value(forKey: "networkHostName")  as? String){
                networkDataHost.text = hostName//(UserDefaults.standard.value(forKey: "networkHostName")  as! String)
                networkDataPort.text = (UserDefaults.standard.value(forKey: "networkPortName")  as! String)
               
                 }
             interfaceValue = vehicleInterface
           
            
        }
            
        else if vehicleInterface == "Pre-recorded Tracefile" {
            if let tracefile = (UserDefaults.standard.value(forKey: "traceInputFilename")  as? String){
            playname.text = tracefile//(UserDefaults.standard.value(forKey: "traceInputFilename")  as! String)
            }
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
        
        networkDataHost.resignFirstResponder()
        networkDataPort.resignFirstResponder()
        playname.resignFirstResponder()
        
        playname.backgroundColor = UIColor.white
        networkDataHost.backgroundColor = UIColor.white
        networkDataPort.backgroundColor = UIColor.white
        
        PopupView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
       self.view.addSubview(PopupView)
        if let vechileInterface = UserDefaults.standard.value(forKey: "vehicleInterface") as? NSString {
            titleLabel.text = vechileInterface as String
            interfaceValue = vechileInterface as String
            self.setValueForRadioBtn()
        }
    }
    //Cancel button on pop up view Action
    @IBAction func cancelBtn(_ sender: AnyObject) {
        
        PopupView.removeFromSuperview()
        self.setValueVehicleInterface()
    }
    //Radio buttons on pop up view Action
    @IBAction func bluetoothBtnAction(_ sender: Any) {
        
        bluetoothBtn.isSelected = true
        networkBtn.isSelected = false
        tracefileBtn.isSelected = false
        noneBtn.isSelected = false
        interfaceValue = "Bluetooth"
        PopupView.removeFromSuperview()
        self.setValueVehicleInterface()
    }
    @IBAction func networkBtnAction(_ sender: Any) {
        
        bluetoothBtn.isSelected = false
        networkBtn.isSelected = true
        tracefileBtn.isSelected = false
        noneBtn.isSelected = false
        interfaceValue = "Network"
        PopupView.removeFromSuperview()
        self.setValueVehicleInterface()
    }
    @IBAction func trscefileBtnAction(_ sender: Any) {
        
        bluetoothBtn.isSelected = false
        networkBtn.isSelected = false
        tracefileBtn.isSelected = true
        noneBtn.isSelected = false
        interfaceValue = "Pre-recorded Tracefile"
        PopupView.removeFromSuperview()
        self.setValueVehicleInterface()
    }
    @IBAction func noneBtnAction(_ sender: Any) {
        
        bluetoothBtn.isSelected = false
        networkBtn.isSelected = false
        tracefileBtn.isSelected = false
        noneBtn.isSelected = true
        interfaceValue = "None"
        PopupView.removeFromSuperview()
        self.setValueVehicleInterface()
    }
    func setValueForRadioBtn(){
        if  (interfaceValue == "Bluetooth") {
            bluetoothBtn.isSelected = true
            networkBtn.isSelected = false
            tracefileBtn.isSelected = false
            noneBtn.isSelected = false
        }else if  (interfaceValue == "Pre-recorded Tracefile") {
            bluetoothBtn.isSelected = false
            networkBtn.isSelected = false
            tracefileBtn.isSelected = true
            noneBtn.isSelected = false
            
        }else if  (interfaceValue == "Network") {
            bluetoothBtn.isSelected = false
            networkBtn.isSelected = true
            tracefileBtn.isSelected = false
            noneBtn.isSelected = false
            
        }else  {
            bluetoothBtn.isSelected = false
            networkBtn.isSelected = false
            tracefileBtn.isSelected = false
            noneBtn.isSelected = true
            
        }
    }
    func setValueVehicleInterface(){
        
        if  (interfaceValue == "None") {
            
            playname.isUserInteractionEnabled = false
            networkDataHost.isUserInteractionEnabled = false
            networkDataPort.isUserInteractionEnabled = false
            
             playname.backgroundColor = UIColor.lightGray
             networkDataHost.backgroundColor = UIColor.lightGray
             networkDataPort.backgroundColor = UIColor.lightGray
    
            UserDefaults.standard.set(interfaceValue, forKey:"vehicleInterface")
            titleLabel.text = interfaceValue
            
            tfm.disableTraceFileSource()
            NM.disconnectConnection()
            if (bm.isBleConnected) {
                bm.disconnect()
            }
            
            networkDataPort.text = ""
            networkDataHost.text = ""
            playname.text = ""
        }
         else if  (interfaceValue == "Pre-recorded Tracefile") {
            playname.isUserInteractionEnabled = true
            
            networkDataHost.backgroundColor = UIColor.lightGray
            networkDataPort.backgroundColor = UIColor.lightGray
            
            networkDataHost.isUserInteractionEnabled = false
            networkDataPort.isUserInteractionEnabled = false
            if let name = UserDefaults.standard.value(forKey: "traceInputFilename") as? NSString {
                playname.text = name as String
            }
            UserDefaults.standard.set(interfaceValue, forKey:"vehicleInterface")
            titleLabel.text = interfaceValue
            NM.disconnectConnection()
            if (bm.isBleConnected) {
                bm.disconnect()
            }
            networkDataPort.text = ""
            networkDataHost.text = ""
        }
        else if  (interfaceValue == "Network") {
            playname.isUserInteractionEnabled = false
            playname.backgroundColor = UIColor.lightGray
            
            networkDataHost.isUserInteractionEnabled = true
            networkDataPort.isUserInteractionEnabled = true
            UserDefaults.standard.set(interfaceValue, forKey:"vehicleInterface")
            titleLabel.text = interfaceValue
            if let name = (UserDefaults.standard.value(forKey: "networkHostName") as? String) {
                networkDataHost.text = name
                networkDataPort.text = (UserDefaults.standard.value(forKey: "networkPortName")  as! String)
            }
            if (bm.isBleConnected) {
                bm.disconnect()
            }
            tfm.disableTraceFileSource()
            playname.text = ""
        }
        else  {
            playname.isUserInteractionEnabled = false
            networkDataHost.isUserInteractionEnabled = false
            networkDataPort.isUserInteractionEnabled = false
            
            playname.backgroundColor = UIColor.lightGray
            networkDataHost.backgroundColor = UIColor.lightGray
            networkDataPort.backgroundColor = UIColor.lightGray
            if  (interfaceValue == "None") {
                titleLabel.text = interfaceValue
            UserDefaults.standard.set("None", forKey:"vehicleInterface")
            }else{
                titleLabel.text = interfaceValue
               UserDefaults.standard.set("Bluetooth", forKey:"vehicleInterface")
            }
            //titleLabel.text = interfaceValue
            
            tfm.disableTraceFileSource()
            NM.disconnectConnection()
            
            networkDataPort.text = ""
            networkDataHost.text = ""
            playname.text = ""
            
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
       // self.hideActivityIndicator()
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
            UserDefaults.standard.set(playname.text, forKey:"traceInputFilename")
            //if let name = UserDefaults.standard.value(forKey: "traceOutputFilename") as? NSString {
            tfm.enableTraceFileSource(playname.text! as NSString)
           
           //}
           
        }
        if textField.tag == 102{
            if (textField.text != ""){
            networkDataPort.becomeFirstResponder()
        }else{
            
            let alertController = UIAlertController(title: "", message:
                "Please enter valid host name", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        }
        if textField.tag == 103{
            if (textField.text != ""){
            self.networkDataFetch(hostName: networkDataHost.text!,PortName: networkDataPort.text!)
                UserDefaults.standard.set(networkDataHost.text!, forKey:"networkHostName")
                UserDefaults.standard.set(networkDataPort.text!, forKey:"networkPortName")
            textField.resignFirstResponder();
            }else{
                let alertController = UIAlertController(title: "", message:
                    "Please enter valid port number", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
   
            }
        }
        return true;
    }
    //ranjan added code for Network data
    func networkDataFetch(hostName:String,PortName:String)  {
        // networkData.text = name as String
        
         //let ip  = hostName
         let port  = Int(PortName)
        if(hostName != "" && PortName != ""){
            NetworkDataManager.sharedInstance.connect(ip:hostName, portvalue: port!, completionHandler: { (success) in
                print(success)
                if(success){
                    UserDefaults.standard.set(hostName, forKey:"networkHostName")
                    UserDefaults.standard.set(PortName, forKey:"networkPortName")
                    //self.callBack()
                }else{
                    let alertController = UIAlertController(title: "", message:
                        "error ocured in connection", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    UserDefaults.standard.set(nil, forKey:"networkHostName")
                    UserDefaults.standard.set(nil, forKey:"networkPortName")
                }
            })
        }

        
    }
    
    
    //ranjan added code for Network data
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
    
    // show 'sources' view
    @IBAction func srcHit(_ sender: AnyObject) {
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
