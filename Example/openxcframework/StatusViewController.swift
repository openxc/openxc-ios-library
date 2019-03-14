//
//  StatusViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework

// TODO: ToDo - Work on removing the warnings


class StatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
   
    
    // UI Labels
    @IBOutlet weak var actConLab: UILabel!
    @IBOutlet weak var msgRvcdLab: UILabel!
    @IBOutlet weak var verLab: UILabel!
    @IBOutlet weak var devidLab: UILabel!
    @IBOutlet weak var platformLab: UILabel!
    @IBOutlet weak var throughputLab: UILabel!
    @IBOutlet weak var NetworkImg: UIImageView!
    
    fileprivate var troughputLoop: Timer!
    // scan/connect button
    @IBOutlet weak var searchBtn: UIButton!
    // disconnect button
    @IBOutlet weak var disconnectBtn: UIButton!
    // table for holding/showing discovered VIs
    @IBOutlet weak var peripheralTable: UITableView!
    
    // the VM
    var vm: VehicleManager!
    var cm: Command!
    var tfm: TraceFileManager!
    var bm: BluetoothManager!

    // timer for UI counter updates
    var timer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.disconnectBtn.isHidden = true
        // change tab bar text colors
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.gray], for:UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for:.selected)
        
        
        // instantiate the VM
        vm = VehicleManager.sharedInstance
        cm = Command.sharedInstance
        tfm = TraceFileManager.sharedInstance
        bm = BluetoothManager.sharedInstance

        // setup the status callback, and the command response callback
        vm.setManagerCallbackTarget(self, action: StatusViewController.manager_status_updates)
        //vm.setCanDefaultTarget(self, action: StatusViewController.handle_cmd_response)
        
        // setup the status callback, and the command response callback
        //cm.setManagerCallbackTarget(self, action: StatusViewController.manager_status_updates)
        vm.setCommandDefaultTarget(self, action: StatusViewController.handle_cmd_response)
        // turn on debug output
        vm.setManagerDebug(true)
    }
    override func viewDidAppear(_ animated: Bool) {
      //  let name = UserDefaults.standard.value(forKey: "networkAdress") as? NSString
        
        
         if let name = (UserDefaults.standard.value(forKey: "vehicleInterface") as? String) {
            if name == "Bluetooth"{
                if (bm.isBleConnected) {
                    DispatchQueue.main.async {
                        
                        self.disconnectBtn.isHidden = false
                       // self.searchBtn.isEnabled = true
                        self.NetworkImg.isHidden = true
                        //self.actConLab.text = "---"
                       //self.msgRvcdLab.text = "---"
                        //self.searchBtn.setTitle("SEARCH FOR BLE VI",for:UIControlState())
                    }
                }else{
                    self.disconnectBtn.isHidden = true
                    self.searchBtn.isEnabled = true
                    self.NetworkImg.isHidden = true
                    self.actConLab.text = "---"
                    self.msgRvcdLab.text = "---"
                    self.searchBtn.setTitle("SEARCH FOR BLE VI",for:UIControlState())
                }
                return
                
            }
            
            if (bm.isBleConnected && !UserDefaults.standard.bool(forKey: "throughputOn")) {
                throughputLab.text = "Off"
            }
            if name == "Network"{
                if (!vm.isNetworkConnected){
                    if let name = (UserDefaults.standard.value(forKey: "networkHostName") as? String) {
                        if let port = (UserDefaults.standard.value(forKey: "networkPortName") as? String){
                            self.networkDataFetch(hostName: name ,PortName: port )
                        }

                    }else{
                        DispatchQueue.main.async {
                            self.actConLab.text = ""
                            self.verLab.text = "---"
                            self.devidLab.text = "---"
                            self.platformLab.text = "---"
                            self.msgRvcdLab.text = "---"
                            self.searchBtn.setTitle("WIFI NOT CONNECTED",for:UIControlState())
                            self.searchBtn.isEnabled = false
                            let alertController = UIAlertController(title: "", message:
                                "please check the host adress", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                        
                    }
                    
                    
                }else{
                    timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(StatusViewController.msgRxdUpdate(_:)), userInfo: nil, repeats: true)
                    DispatchQueue.main.async {
                        
                        self.NetworkImg.isHidden = false
                        self.actConLab.text = ""
                        self.verLab.text = "---"
                        self.devidLab.text = "---"
                        self.platformLab.text = "---"
                        //self.msgRvcdLab.text = "---"
                        self.searchBtn.setTitle("WIFI  CONNECTED",for:UIControlState())
                        self.searchBtn.isEnabled = false
                    }
                }
                return
            }
         
            
            if name == "None"{
                DispatchQueue.main.async {
                    self.actConLab.text = "---"
                    self.msgRvcdLab.text = "---"
                    self.verLab.text = "---"
                    self.devidLab.text = "---"
                    self.platformLab.text = "---"
                    self.searchBtn.setTitle("None",for:UIControlState())
                    self.searchBtn.isEnabled = false
                }
                return
            }
            
            if name == "Pre-recorded Tracefile"{
                if let traceFileName = UserDefaults.standard.value(forKey: "traceInputFilename") as? NSString{
                    timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(StatusViewController.msgRxdUpdate(_:)), userInfo: nil, repeats: true)
                    if(!vm.isTraceFileConnected){
                        tfm.enableTraceFileSource(traceFileName)
                        self.searchBtn.isEnabled = false
                        DispatchQueue.main.async {
                            self.actConLab.text = "✅"
                            self.searchBtn.setTitle("Trace File Playing",for:UIControlState())
                            self.verLab.text = "---"
                            self.devidLab.text = "---"
                            self.platformLab.text = "---"
                        }
                    }else{
                        
                        DispatchQueue.main.async {
                            self.actConLab.text = "✅"
                            self.searchBtn.setTitle("Trace File Playing",for:UIControlState())
                            
                        }
                    }
                }
                return
            }
         } else{
            
//            self.searchBtn.isEnabled = true
//            self.NetworkImg.isHidden = true
//            self.actConLab.text = "---"
//            self.msgRvcdLab.text = "---"
//            self.searchBtn.setTitle("SEARCH FOR BLE VI",for:UIControlState())
            
        }
       
        // check to see if a trace input file has been set up

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
                     self.timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(StatusViewController.msgRxdUpdate(_:)), userInfo: nil, repeats: true)
                    if self.bm.messageCount > 0{
                    UserDefaults.standard.set(hostName, forKey:"networkHostName")
                    UserDefaults.standard.set(PortName, forKey:"networkPortName")
                    DispatchQueue.main.async {
                        
                        self.NetworkImg.isHidden = true
                        self.actConLab.text = ""
                        self.verLab.text = "---"
                        self.devidLab.text = "---"
                        self.platformLab.text = "---"
                        self.searchBtn.setTitle("WIFI CONNECTED",for:UIControlState())
                        self.searchBtn.isEnabled = false
                    }
                 }
                    //self.callBack()
                }else{
                    DispatchQueue.main.async {
                        self.actConLab.text = ""
                        self.verLab.text = "---"
                        self.devidLab.text = "---"
                        self.platformLab.text = "---"
                        self.msgRvcdLab.text = "---"
                        self.searchBtn.setTitle("WIFI NOT CONNECTED",for:UIControlState())
                        self.searchBtn.isEnabled = false
                        let alertController = UIAlertController(title: "", message:
                            "error ocured in connection", preferredStyle: UIAlertControllerStyle.alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                }
            })
        }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func calculateThroughput(){
     let value = bm.calculateThroughput()
        self.throughputLab.text = value
    }
    // this function is called when the scan button is hit
    @IBAction func searchHit(_ sender: UIButton) {
        
        // make sure we're not already connected first
        if (bm.connectionState==VehicleManagerConnectionState.notConnected) {
            
            // start a timer to update the UI with the total received messages
            timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(StatusViewController.msgRxdUpdate(_:)), userInfo: nil, repeats: true)
            
            // check to see if the config is set for autoconnect mode
            bm.setAutoconnect(false)
            if UserDefaults.standard.bool(forKey: "autoConnectOn") {
                bm.setAutoconnect(true)
            }
                vm.setThroughput(false)
            if  UserDefaults.standard.bool(forKey: "throughputOn"){
                //print(UserDefaults.standard.bool(forKey: "throughputOn"))
                vm.setThroughput(true)
                troughputLoop = Timer.scheduledTimer(timeInterval: 5.0, target:self, selector:#selector(calculateThroughput), userInfo: nil, repeats:true)
            }
            // check to see if the config is set for protobuf mode
            self.vm.setProtobufMode(false)
            if UserDefaults.standard.bool(forKey: "protobufOn") {
                self.vm.setProtobufMode(true)
            }
            
            // check to see if a trace input file has been set up
            //if UserDefaults.standard.bool(forKey: "traceInputOn") {
           // if let name = UserDefaults.standard.value(forKey: "traceInputFilename") as? NSString {
                  //  vm.enableTraceFileSource(name)
                   // self.searchBtn.isEnabled = false
               
               // }
           // }
            
            
            // check to see if a trace output file has been configured
            if UserDefaults.standard.bool(forKey: "traceOutputOn") {
                if let name = UserDefaults.standard.value(forKey: "traceOutputFilename") as? NSString {
                    
                    if !vm.isTraceFileConnected == true{
                             tfm.enableTraceFileSink(name)
                    }else{
                        let alertController = UIAlertController (title: "Setting", message: "Please Disable pre record tracefile in data source", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            // start the VI scan
            bm.scan(completionHandler:{(success) in

                // update the UI
                if(!success){
                    let alertController = UIAlertController (title: "Setting", message: "Please enable Bluetooth", preferredStyle: .alert)
                    let url = URL(string: "App-Prefs:root=Bluetooth")
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        guard URL(string: UIApplicationOpenSettingsURLString) != nil else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(url!) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(url!, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                    
                                })
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                    alertController.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                DispatchQueue.main.async {
                    self.actConLab.text = "❓"
                    self.searchBtn.setTitle("SCANNING",for:UIControlState())
                    //                    let alertController = UIAlertController(title: "", message:
                    //                        "Please check the BLE power is on ", preferredStyle: UIAlertControllerStyle.alert)
                    //                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                    //                    self.present(alertController, animated: true, completion: nil)
                }
                
            })

        }
    }
    
    // this function receives all status updates from the VM
    func manager_status_updates(_ rsp:NSDictionary) {
        
        // extract the status message
        let status = rsp.object(forKey: "status") as! Int
        let msg = VehicleManagerStatusMessage(rawValue: status)
       
        
        // show/reload the table showing detected VIs
        if msg==VehicleManagerStatusMessage.c5DETECTED {
            DispatchQueue.main.async {
                self.peripheralTable.isHidden = false
                self.peripheralTable.reloadData()
            }
        }
        
        // update the UI showing connected VI
        if msg==VehicleManagerStatusMessage.c5CONNECTED {
            vm.setCommandDefaultTarget(self, action: StatusViewController.handle_cmd_response)
            DispatchQueue.main.async {
                self.disconnectBtn.isHidden = false
                self.peripheralTable.isHidden = true
                self.actConLab.text = "✅"
                self.NetworkImg.isHidden = true
                self.searchBtn.setTitle("BLE VI CONNECTED",for:UIControlState())
              
            }
        }
        if (vm.isNetworkConnected) {
            DispatchQueue.main.async {
                self.peripheralTable.isHidden = true
                self.actConLab.text = ""
                self.NetworkImg.isHidden = false
                self.searchBtn.setTitle("WIFI CONNECTED",for:UIControlState())
                self.searchBtn.isEnabled = false
                
            }
        }
      
        // update the UI showing disconnected VI
        if msg==VehicleManagerStatusMessage.c5DISCONNECTED {
            if(!vm.isTraceFileConnected){
            DispatchQueue.main.async {
                self.actConLab.text = "---"
                self.msgRvcdLab.text = "---"
                self.verLab.text = "---"
                self.devidLab.text = "---"
                self.platformLab.text = "---"
                self.searchBtn.setTitle("SEARCH FOR BLE VI",for:UIControlState())
                self.disconnectBtn.isHidden = true
            }

            }
        }
        
        // when we see that notify is on, we can send the command requests
        // for version and device id, one after the other
        if msg==VehicleManagerStatusMessage.c5NOTIFYON {
            
            let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                let cm = VehicleCommandRequest()
                cm.command = .version
                self.cm.sendCommand(cm)
            }
            
            let delayTime2 = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime2) {
                let cm = VehicleCommandRequest()
                cm.command = .device_id
                self.cm.sendCommand(cm)
            }
            let delayTime3 = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime3) {
                let cm = VehicleCommandRequest()
                cm.command = .platform
                self.cm.sendCommand(cm)
            }
        }
 
    }
    
//    if  UserDefaults.standard.bool(forKey: "throughputOn"){
//    if bm.isBleConnected{
//    //print(UserDefaults.standard.bool(forKey: "throughputOn"))
//    vm.setThroughput(true)
//    troughputLoop = Timer.scheduledTimer(timeInterval: 5.0, target:self, selector:#selector(calculateThroughput), userInfo: nil, repeats:true)
//    }
//    }
    // this function handles all command responses
    func handle_cmd_response(_ rsp:NSDictionary) {
        
      
        // extract the command response message
        let cr = rsp.object(forKey: "vehiclemessage") as! VehicleCommandResponse
        
        // update the UI depending on the command type- version,device_id works for JSON mode, not in protobuf - TODO
        
        var cvc:CommandsViewController?
        let vcCount = self.tabBarController?.viewControllers?.count
        cvc = self.tabBarController?.viewControllers?[vcCount!-1] as! CommandsViewController?
        
        if cr.command_response.isEqual(to: "version") || cr.command_response.isEqual(to: ".version") {
            DispatchQueue.main.async {
                self.verLab.text = cr.message as String
            }
            cvc?.versionResp = String(cr.message)
        }
        if cr.command_response.isEqual(to: "device_id") || cr.command_response.isEqual(to: ".deviceid"){
            DispatchQueue.main.async {
                self.devidLab.text = cr.message as String
            }
            cvc?.deviceIdResp = String(cr.message)
            
        }
        if cr.command_response.isEqual(to: "platform") || cr.command_response.isEqual(to: ".platform") {

            DispatchQueue.main.async {
                self.platformLab.text = cr.message as String
            }
            cvc?.platformResp = String(cr.message)
            
        }
    }
    
    
    // this function is called by the timer, it updates the UI
    @objc func msgRxdUpdate(_ t:Timer) {
        if bm.connectionState == VehicleManagerConnectionState.operational || vm.isNetworkConnected || vm.isTraceFileConnected{
           
             DispatchQueue.main.async {
                self.msgRvcdLab.text = String(self.bm.messageCount)
            }
        }
    }
    
    // this function is called when the scan button is hit
    @IBAction func disconnectHit(_ sender: UIButton) {
        
        print(" in disconnect")
        print(bm.connectionState)
        
        // make sure we're not already connected first
        if (bm.isBleConnected) {
            bm.disconnect()
        }
    }
    
    // table view delegate functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // how many VIs have been discovered

        tableView.dataSource = self
        
        let count = bm.discoveredVI().count
        return count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // grab a cell
        var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        }
        
        // grab the name of the VI for this row
        let p = bm.discoveredVI()[indexPath.row] as String
        
        // display the name of the VI
        cell!.textLabel?.text = p
        cell!.textLabel?.font = UIFont(name:"Arial", size: 14.0)
        cell!.textLabel?.textColor = UIColor.lightGray
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // if a row is selected, connect to the selected VI
        let p = bm.discoveredVI()[indexPath.row] as String
        bm.connect(p)
        
    }
}

