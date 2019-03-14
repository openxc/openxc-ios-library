//
//  OutputViewController.swift
//  openXCenabler
//
//  Created by Ranjan, Kumar sahu (K.) on 16/01/19.
//  Copyright © 2019 Ford Motor Company. All rights reserved.
//

import UIKit

class OutputViewController: UIViewController {

    @IBOutlet weak var overwriteGPSswitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

         let overwriteOn =  UserDefaults.standard.bool(forKey: "overwriteGPSOn")
        print(overwriteOn)
         if overwriteOn == true{
              overwriteGPSswitch.isOn = true
        }
        // Do any additional setup after loading the view.
    }
    // close modal view
    @IBAction func hideHit(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func overwriteGPSChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"overwriteGPSOn")
        if sender.isOn {
            overwriteGPSswitch.isOn = true
            self.getVechilegpsData()
        } else {
            overwriteGPSswitch.isOn = false
        }
    }
    func getVechilegpsData(){
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
