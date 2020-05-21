//
//  OutputViewController.swift
//  openXCenabler
//
//  Created by Ranjan, Kumar sahu (K.) on 16/01/19.
//  Copyright © 2019 Ford Motor Company. All rights reserved.
//

import UIKit

class OutputViewController: UIViewController {
    
    @IBOutlet weak var overwriteGPSSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let overwriteOn =  UserDefaults.standard.bool(forKey: "overwriteGPSOn")
        if overwriteOn == true{
            overwriteGPSSwitch.isOn = true
        }
    
    }
    // close modal view
    @IBAction func hideHit(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func overwriteGPSChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"overwriteGPSOn")
        if sender.isOn {
            overwriteGPSSwitch.isOn = true
        } else {
            overwriteGPSSwitch.isOn = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
