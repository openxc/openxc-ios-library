//
//  CanViewController.swift
//  openXCenabler
//
//  Created by Tim Buick on 2016-08-04.
//  Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
//

import UIKit
import openXCiOSFramework


class CanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var canTable: UITableView!

  var vm: VehicleManager!
  var bm: BluetoothManager!
  // dictionary holding CAN key/CAN message from measurement messages
  var canDict: NSMutableDictionary!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // grab VM instance
    vm = VehicleManager.sharedInstance

    bm = BluetoothManager.sharedInstance

    // initialize dictionary/table
    canDict = NSMutableDictionary()
    canTable.reloadData()
    
    // set default CAN target
    vm.setCanDefaultTarget(self, action: CanViewController.default_can_change)
    
   
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
  
  func default_can_change(_ rsp:NSDictionary) {
    // extract the CAN message
    let vr = rsp.object(forKey: "vehiclemessage") as! VehicleCanResponse
   
    // create CAN key from measurement message
    let key = String(format:"%x-%x",vr.bus,vr.id)
    let val = "0x"+(vr.data as String)
 
    // save the CAN key and can message in the dictionary
    canDict.setObject(vr, forKey:key as NSCopying)
    
    // update the table
    DispatchQueue.main.async {
      self.canTable.reloadData()
    }
    
  }
  
  
  
  
  
  
  
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // table size based on what's in the dictionary
    return canDict.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?
    if (cell == nil) {
      cell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
    }
    
    // sort the name keys alphabetically
    let sortedKeys = (canDict.allKeys as! [String]).sorted(by: <)
    
    // grab a CAN key based on the table row
    let k = sortedKeys[indexPath.row]
    
    // grab the CAN message based on the CAN key
    let cr = canDict.object(forKey: k) as! VehicleCanResponse
    
    // convert timestamp to a normal time
    let date = Date(timeIntervalSince1970: Double(cr.timestamp/1000))
    let dayTimePeriodFormatter = DateFormatter()
    dayTimePeriodFormatter.dateFormat = "hh:mm:ss"
    let dateString = dayTimePeriodFormatter.string(from: date)
    
    // show the table row with the important contents of the CAN message
    cell!.textLabel?.text = String(format:"%@  %2d  0x%3x   0x",dateString,cr.bus,cr.id)+(cr.data as String)
    cell!.textLabel?.font = UIFont(name:"Courier New", size: 14.0)
    cell!.textLabel?.textColor = UIColor.lightGray
    
    
    cell!.backgroundColor = UIColor.clear
    
    
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // selecting this table does nothing    
  }
  




}

