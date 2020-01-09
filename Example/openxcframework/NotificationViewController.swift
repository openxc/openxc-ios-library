//
//  NotificationViewController.swift
//  openxcframework_Example
//
//  Created by Ranjan, Kumar sahu (K.) on 09/01/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit


class NotificationViewController: UIViewController {
    
    @IBOutlet weak var dropSwitch: UISwitch!
    @IBOutlet weak var networkSwitch: UISwitch!
    @IBOutlet weak var usbSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let powerDropOn = UserDefaults.standard.bool(forKey: "powerDropChange")
        // update UI if necessary
        if powerDropOn == true {
            dropSwitch.setOn(true, animated:false)
        }
        
        let networkDropOn = UserDefaults.standard.bool(forKey: "networkDropChange")
        // update UI if necessary
        if networkDropOn == true {
            networkSwitch.setOn(true, animated:false)
        }
        
        let usbDropOn = UserDefaults.standard.bool(forKey: "usbDropChange")
        // update UI if necessary
        if usbDropOn == true {
            usbSwitch.setOn(true, animated:false)
        }
    }
    
    // close modal view
    @IBAction func hideHit(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func powerDropChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"powerDropChange")
        if sender.isOn {
        }else{
            
        }
    }
    @IBAction func networkDropChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"networkDropChange")
        if sender.isOn {
        }else{
            
        }
    }
    @IBAction func usbDropChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"usbDropChange")
        if sender.isOn {
        }else{
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
