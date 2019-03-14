//
//  AlertHandling.swift
//  openXCenabler
//
//  Created by Ranjan, Kumar sahu (K.) on 23/01/18.
//  Copyright © 2018 Ford Motor Company. All rights reserved.
//

import UIKit

open class AlertHandling : NSObject {

    static let _sharedInstance = AlertHandling()
    public var alert:UIAlertController?
    
//    fileprivate init(){
//    }
//
//   open class var sharedInstance:AlertHandling{
//        return _sharedInstance
//    }
    // Initialization
    static open let sharedInstance: AlertHandling = {
        let instance = AlertHandling()
        return instance
    }()
    fileprivate override init() {
        //connecting = false
    }
    
   open func showAlert(onViewController viewController:UIViewController, withText text:String, withMessage message:String, style:UIAlertControllerStyle = .alert, actions:UIAlertAction...){
        alert = UIAlertController(title: text, message: message, preferredStyle: style)
        if actions.count == 0{
            alert!.addAction(self.getAlertAction(withTitle: "OK", handler: { _ -> Void in
                self.alert!.dismiss(animated: true, completion: nil)
            }))
        }
        else{
            for action in actions{
                alert!.addAction(action)
            }
        }
        viewController.present(alert!, animated: true, completion: nil)
    }
    
    open func getAlertAction(withTitle title:String, style:UIAlertActionStyle = .default, handler:((UIAlertAction)->Void)?)->UIAlertAction{
        return UIAlertAction(title: title, style: style, handler: handler)
    }

}
