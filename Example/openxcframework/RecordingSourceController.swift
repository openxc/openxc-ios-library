//
//  RecordingSourceController.swift
//  openXCenabler
//
//  Created by Ranjan, Kumar sahu (K.) on 22/03/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import UIKit
import openXCiOSFramework
class RecordingSourceController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var recswitch: UISwitch!
    @IBOutlet weak var recname: UITextField!
    @IBOutlet weak var dweetswitch: UISwitch!
    @IBOutlet weak var dweetname: UITextField!
    @IBOutlet weak var dweetnamelabel: UILabel!
    @IBOutlet weak var uploadtraceswitch: UISwitch!
    @IBOutlet weak var traceURLname: UITextField!
    @IBOutlet weak var tergetURLnamelabel: UILabel!
    
    // the VM
    var vm: VehicleManager!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // grab VM instance
        vm = VehicleManager.sharedInstance
        // watch for changes to trace file output file name field
        recname.addTarget(self, action: #selector(recFieldDidChange), for: UIControlEvents.editingChanged)
        recname.isHidden = true
        
        // watch for changes to dweet name field
        dweetname.addTarget(self, action: #selector(dweetFieldDidChange), for: UIControlEvents.editingChanged)
        dweetname.addTarget(self, action: #selector(keyboardWillShow), for: UIControlEvents.editingDidBegin)
        dweetname.addTarget(self, action: #selector(keyboardWillHide), for: UIControlEvents.editingDidEnd)
        dweetname.isHidden = true
        dweetnamelabel.isHidden = true
        
        
        // watch for changes to dweet name field
        traceURLname.addTarget(self, action: #selector(traceURLFieldDidChange), for: UIControlEvents.editingChanged)
        traceURLname.addTarget(self, action: #selector(keyboardWillShow), for: UIControlEvents.editingDidBegin)
        traceURLname.addTarget(self, action: #selector(keyboardWillHide), for: UIControlEvents.editingDidEnd)
        traceURLname.isHidden = true
        tergetURLnamelabel.isHidden = true
        
        //UserDefaults.standard.set(interfaceValue, forKey:"vehicleInterface")
        let value =  UserDefaults.standard.string(forKey: "vehicleInterface")
        print(value)
        // check saved value of trace Sink switch
        let traceOutOn = UserDefaults.standard.bool(forKey: "uploadTaraceOn")
        print(traceOutOn)
        // update UI if necessary
        if traceOutOn == true {
            uploadtraceswitch.setOn(true, animated:false)
            traceURLname.isHidden = false
            tergetURLnamelabel.isHidden = false
        }
        // check saved value of trace output switch
        let traceSinkOn = UserDefaults.standard.bool(forKey: "traceOutputOn")
        // update UI if necessary
        if traceSinkOn == true {
            recswitch.setOn(true, animated:false)
            recname.isHidden = false
        }
        if let name = UserDefaults.standard.value(forKey: "traceOutputFilename") as? NSString {
            recname.text = name as String
        }
        if let name = UserDefaults.standard.value(forKey: "traceURLname") as? NSString {
            traceURLname.text = name as String
        }
        // at first run, get a random dweet name
        if UserDefaults.standard.string(forKey: "dweetname") == nil {
            let name : NSMutableString = ""
            
            var fileroot = Bundle.main.path(forResource: "adjectives", ofType:"txt")
            if fileroot != nil {
                do {
                    let filecontents = try String(contentsOfFile: fileroot!)
                    let allLines = filecontents.components(separatedBy: CharacterSet.newlines)
                    let randnum = Int(arc4random_uniform(UInt32(allLines.count)))
                    name.append(allLines[randnum])
                } catch {
                    
                    var randnum = arc4random_uniform(26)
                    name.appendFormat("%c",65+randnum)
                    randnum = arc4random_uniform(26)
                    name.appendFormat("%c",65+randnum)
                }
            } else {
                
                var randnum = arc4random_uniform(26)
                name.appendFormat("%c",65+randnum)
                randnum = arc4random_uniform(26)
                name.appendFormat("%c",65+randnum)
            }
            
            name.append("-")
            
            fileroot = Bundle.main.path(forResource: "nouns", ofType:"txt")
            if fileroot != nil {
                do {
                    let filecontents = try String(contentsOfFile: fileroot!)
                    let allLines = filecontents.components(separatedBy: CharacterSet.newlines)
                    let randnum = Int(arc4random_uniform(UInt32(allLines.count)))
                    name.append(allLines[randnum])
                } catch {
                    
                    var randnum = arc4random_uniform(10)
                    name.appendFormat("%c",30+randnum)
                    randnum = arc4random_uniform(10)
                    name.appendFormat("%c",30+randnum)
                }
            } else {
                
                var randnum = arc4random_uniform(10)
                name.appendFormat("%c",30+randnum)
                randnum = arc4random_uniform(10)
                name.appendFormat("%c",30+randnum)
            }
            UserDefaults.standard.setValue(name, forKey:"dweetname")
            
        }
        // load the dweet name into the text field
        //dweetname.text = UserDefaults.standard.string(forKey: "dweetname")
        // check value of dweet out switch
        let dweetOn = UserDefaults.standard.bool(forKey: "dweetOutputOn")
        // update UI if necessary
        if dweetOn == true {
            dweetswitch.setOn(true, animated:false)
            dweetname.isHidden = false
            dweetnamelabel.isHidden = false
        }
        
    }
    // the trace output enabled switch changed, save it's new value
    // and show or hide the text field for filename accordingly
    @IBAction func recChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"traceOutputOn")
        if sender.isOn {
            recname.isHidden = false
        } else {
            recname.isHidden = true
        }
    }
    @IBAction func dweetChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"dweetOutputOn")
        if sender.isOn {
            dweetname.isHidden = false
            dweetnamelabel.isHidden = false
        } else {
            dweetname.isHidden = true
            dweetnamelabel.isHidden = true
        }
    }
    @IBAction func uploadTraceChange(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey:"uploadTaraceOn")
        if sender.isOn {
            traceURLname.isHidden = false
            tergetURLnamelabel.isHidden = false
        } else {
            traceURLname.isHidden = true
            tergetURLnamelabel.isHidden = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hideHit(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // dweet output name changed, save it in nsuserdefaults
    @objc func dweetFieldDidChange(_ textField: UITextField) {
        UserDefaults.standard.set(textField.text, forKey:"dweetname")
    }
    // text view delegate to clear keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
       
        if textField.tag == 103 {
            let str = textField.text
            if str!.range(of:".json") != nil {
                
                UserDefaults.standard.set(textField.text, forKey:"traceOutputFilename")
            }else{
                let alertController = UIAlertController(title: "", message:
                    "Plese specify file Name with .json", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
        if textField.tag == 105{
   
            print(textField.text as Any)
            if textField.text != "http://"{
                 UserDefaults.standard.set(textField.text, forKey:"traceURLname")
                
            }else{
                let alertController = UIAlertController(title: "", message:
                    "Plese specify target URL Name ", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        return true;
    }
    
  
    
    // trace file output file name changed, save it in nsuserdefaults
    @objc func recFieldDidChange(_ textField: UITextField) {
        
        UserDefaults.standard.set(textField.text, forKey:"traceOutputFilename")
        
    }
    // trace file output file name changed, save it in nsuserdefaults
    @objc func traceURLFieldDidChange(_ textField: UITextField) {
        
       // UserDefaults.standard.set(textField.text, forKey:"traceURLname")
        
    }
    @objc func keyboardWillShow() {
        if view.frame.origin.y == 0{
            self.view.frame.origin.y -= 120
        }
    }
    
    @objc func keyboardWillHide() {
        if view.frame.origin.y != 0 {
            self.view.frame.origin.y += 120
        }
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
