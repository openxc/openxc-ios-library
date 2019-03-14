//
//  DashboardViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework
import CoreMotion
import CoreLocation
import AVFoundation


// TODO: ToDo - Work on removing the warnings

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, NSURLConnectionDelegate {

  // measurement table
  @IBOutlet weak var dashTable: UITableView!
  
  
  var vm: VehicleManager!
  var bm : BluetoothManager!
  var tfm : TraceFileManager!
  var vmu :VehicleMessageUnit!
  // dictionary holding name/value from measurement messages
  var dashDict: NSMutableDictionary!
  
  // sensor related vars
  fileprivate var sensorLoop: Timer = Timer()
  fileprivate var headphones : String = "No"
  fileprivate var motionManager : CMMotionManager = CMMotionManager()
  fileprivate var locationManager : CLLocationManager = CLLocationManager()
  fileprivate var lat : Double = 0
  fileprivate var long : Double = 0
  fileprivate var alt : Double = 0
  fileprivate var head : Double = 0
  fileprivate var speed : Double = 0.0
  
  // dweet related vars
  fileprivate var dweetLoop: Timer = Timer()
  fileprivate var dweetConn: NSURLConnection?
  fileprivate var dweetRspData: NSMutableData?
  
    // TraceURL related vars
    fileprivate var traceURLLoop: Timer = Timer()
    fileprivate var traceConn: NSURLConnection?
    fileprivate var traceRspData: NSMutableData?
    fileprivate var traceSinkLoop: Timer = Timer()
   
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // grab VM instance
    vm = VehicleManager.sharedInstance
    vmu = VehicleMessageUnit.sharedInstance
    bm = BluetoothManager.sharedInstance
    tfm = TraceFileManager.sharedInstance

    // initialize dictionary/table
    dashDict = NSMutableDictionary()
    dashTable.reloadData()
    
    // set default measurement target
    vm.setMeasurementDefaultTarget(self, action: DashboardViewController.default_measurement_change)

    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=500;
    locationManager.requestWhenInUseAuthorization()

   self.sendTraceURLData()
  }
    @objc func sendTraceURLData() {
        if UserDefaults.standard.bool(forKey: "uploadTaraceOn") {
               if let urlname = (UserDefaults.standard.value(forKey: "traceURLname") as? String) {
                if dashDict.allKeys.count>0{
                vm.sendTraceURLData(urlName:urlname,rspdict: dashDict,isdrrsp:false)
                }
                }
             }
        
        
    }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !bm.isBleConnected {
    dashDict = NSMutableDictionary()
      dashTable.reloadData()
    }
    sensorLoop.invalidate()
    locationManager.stopUpdatingLocation()
    motionManager.stopDeviceMotionUpdates()
    
    dweetLoop.invalidate()
    
    
    if  UserDefaults.standard.bool(forKey: "sensorsOn") !=
        UserDefaults.standard.bool(forKey: "lastSensorsOn") {
      // clear the table if the sensor value changes
      dashDict = NSMutableDictionary()
      dashTable.reloadData()
    }
    UserDefaults.standard.set(UserDefaults.standard.bool(forKey: "sensorsOn"), forKey:"lastSensorsOn")
    
    if UserDefaults.standard.bool(forKey: "sensorsOn") {
      
      sensorLoop = Timer.scheduledTimer(timeInterval: 0.25, target:self, selector:#selector(sensorUpdate), userInfo: nil, repeats:true)
    
      if CLLocationManager.locationServicesEnabled() {
        locationManager.startUpdatingLocation()
      }
      
      motionManager.deviceMotionUpdateInterval = 0.05
      motionManager.startDeviceMotionUpdates()
      
    }
  
    if UserDefaults.standard.bool(forKey: "dweetOutputOn") {
      dweetLoop = Timer.scheduledTimer(timeInterval: 1.5, target:self, selector:#selector(sendDweet), userInfo: nil, repeats:true)
    }
    //Used for checking the trece sink is enabled or not then start the timer if on.
    if UserDefaults.standard.bool(forKey: "uploadTaraceOn") {
        traceSinkLoop = Timer.scheduledTimer(timeInterval: 2.5, target:self, selector:#selector(sendTraceURLData), userInfo: nil, repeats:true)
    }
    if(!bm.isBleConnected && !vm.isTraceFileConnected && !vm.isNetworkConnected){
        AlertHandling.sharedInstance.showAlert(onViewController: self, withText: errorMSG, withMessage:errorMsgBLE)
        dashDict = NSMutableDictionary()
        dashTable.reloadData()
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  func default_measurement_change(_ rsp:NSDictionary) {
    // extract the measurement message
    let vr = rsp.object(forKey: "vehiclemessage") as! VehicleMeasurementResponse
    
    // take name and value from measurement message
    let name = vr.name as NSString
    var val = vr.value as AnyObject
    // make sure we don't have any nulls in the dictionary, better to have blank strings
    if val.isEqual(NSNull()) {
      val="" as AnyObject
    }
    if vr.isEvented {
      var e:NSString
      if vr.event is NSNumber {
        let ne = vr.event as! NSNumber
        if ne.isEqual(to: NSNumber(value: true)) {
          e = "true";
        } else if ne.isEqual(to: NSNumber(value:false)) {
          e = "true";
        } else {
          // round any floating points
            let ner = Double(round(10.0*Double(truncating: ne))/10)
          e = String(ner) as NSString
        }
      } else {
        e = vr.event.description as NSString
      }
      val = NSString(format:"%@:%@",vr.value.description,e)
    }
    // save the name key and value in the dictionary
    dashDict.setObject(val, forKey:name)
 

    // update the table
    DispatchQueue.main.async {
        self.dashTable.reloadData()
    }
    if vr.isEvented {
      
    } else {
     
    }
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // table size based on what's in the dictionary
    return dashDict.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
    }

    // sort the name keys alphabetically
    let sortedKeys = (dashDict.allKeys as! [String]).sorted(by: <)
    
    // grab a name key based on the table row
    let k = sortedKeys[indexPath.row]
    
    // grab the value based on the name key
    let v = dashDict.object(forKey: k)

    //let valueMeasurement  = vmu.getMesurementUnit(key: k, value: v as AnyObject)

   //print(valueMeasurement)
    // main text in table is the measurement name
    cell!.textLabel?.text = k
    cell!.textLabel?.font = UIFont(name:"Arial", size: 13.0)
    cell!.textLabel?.textColor = UIColor.lightGray
    
    // figure out if the value is a bool/number/string
    if v is NSNumber {
      let nv = v as! NSNumber
      if nv.isEqual(to: NSNumber(value: true as Bool)) {
        cell!.detailTextLabel?.text = "On"
      } else if nv.isEqual(to: NSNumber(value: false as Bool)) {
        cell!.detailTextLabel?.text = "Off"
      } else {
        // round any floating points
        let nvr = Double(round(10.0*Double(nv))/10)
        let valueMeasure1 = String(format:"%.2f",nvr)
        let valueMeasure = vmu.getMesurementUnit(key: k, value: valueMeasure1 as AnyObject)
        cell!.detailTextLabel?.text = (valueMeasure as! String)
      }
    } else {
       // if valueMeasurement is NSNumber {
        let floatvalue = (v as AnyObject).doubleValue
        let nvr = Double(round(10.0*Double(floatvalue!))/10)
        if nvr != 0.0{
            let valueMeasure1 = String(format:"%.2f",nvr)
            let valueMeasure = vmu.getMesurementUnit(key: k, value: valueMeasure1 as AnyObject)
            cell!.detailTextLabel?.text = (valueMeasure as! String)//(valueMeasurement as AnyObject).description
        }
       else{
            cell!.detailTextLabel?.text = (v as AnyObject).description
        }
    }
    cell!.detailTextLabel?.font = UIFont(name:"Arial", size: 13.0)
    cell!.detailTextLabel?.textColor = UIColor.lightGray
    
    cell!.backgroundColor = UIColor.clear
    
    
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // selecting this table does nothing
  }

  
  
  @objc func sensorUpdate() {
    
    if isHeadsetPluggedIn() {
      dashDict.setObject("Yes", forKey:"phone_headphones_attached" as NSCopying)
    } else {
      dashDict.setObject("No", forKey:"phone_headphones_attached" as NSCopying)
       
    }

    dashDict.setObject(UIScreen.main.brightness, forKey:"phone_brightness" as NSCopying)

    if let motion = motionManager.deviceMotion {
      let p = 180/M_PI*motion.attitude.pitch;
      let r = 180/M_PI*motion.attitude.roll;
      let y = 180/M_PI*motion.attitude.yaw;
      dashDict.setObject(p, forKey:"phone_motion_pitch" as NSCopying)
      dashDict.setObject(r, forKey:"phone_motion_roll" as NSCopying)
      dashDict.setObject(y, forKey:"phone_motion_yaw" as NSCopying)
    }
   
    // update the table
    DispatchQueue.main.async {
      self.dashTable.reloadData()
    }
    
  }
  

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    if locations.count>0 {
  
      let loc = locations.last!
      dashDict.setObject(loc.coordinate.latitude, forKey:"phone_latitude" as NSCopying)
      dashDict.setObject(loc.coordinate.longitude, forKey:"phone_longitude" as NSCopying)
      dashDict.setObject(loc.altitude, forKey:"phone_altitude" as NSCopying)
      dashDict.setObject(loc.course, forKey:"phone_heading" as NSCopying)
      dashDict.setObject(loc.speed, forKey:"phone_speed" as NSCopying)
      // update the table
      DispatchQueue.main.async {
        self.dashTable.reloadData()
      }

    }
  }
  
  func isHeadsetPluggedIn() -> Bool {
    let route = AVAudioSession.sharedInstance().currentRoute
    for desc in route.outputs {
      if desc.portType == AVAudioSessionPortHeadphones {
        return true
      }
    }
    return false
  }
  

  @objc func sendDweet() {
    
    if let conn = dweetConn {
      // connection already exists!
      conn.cancel()
    }
    dweetConn = nil
    dweetRspData = NSMutableData()
    
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: dashDict, options: .prettyPrinted)
      
      if let dweetname = UserDefaults.standard.string(forKey: "dweetname") {
        let urlStr = URL(string:"https://dweet.io/dweet/for/"+dweetname)
        let postLength = String(format:"%lu", Double(jsonData.count))
        
       // let request = NSMutableURLRequest()
        var request:URLRequest = URLRequest(url: urlStr!)
        let session = URLSession.shared
        request.url = urlStr
        request.httpMethod = "POST"
        request.setValue(postLength,forHTTPHeaderField:"Content-Length")
        request.setValue("application/json", forHTTPHeaderField:"Content-Type")
        request.httpBody = jsonData
        
        // TODO: ToDo - Change NSURLConnection to NSURLSession
        //dweetConn = NSURLConnection(request: request as URLRequest, delegate: self, startImmediately:true)
        //[[[URLSession, sharedSession] dataTaskWithRequest:request] resume]
        let task = session.dataTask(with: request)
        task.resume()
      }
      
    } catch {
    
    }
    
  
    
  }
    private func connection(_ connection: NSURLConnection!, didReceiveData data: Data!){
    dweetRspData?.append(data)
  
    
  }
  
  func connectionDidFinishLoading(_ connection: NSURLConnection!) {
    
    //let responseString = String(data:dweetRspData!,encoding:NSUTF8StringEncoding)
    
  }
    
  
}

