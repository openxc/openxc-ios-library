//
//  SendCanView_UITests.swift
//  openxcframework_UITests
//
//  Created by Ranjan, Kumar sahu (K.) on 27/08/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class SendCanView_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testTextField() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["More"].tap()
        
        let window = app.children(matching: .window).element(boundBy: 0)
        let element3 = window.children(matching: .other).element.children(matching: .other).element
        let element = element3.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.children(matching: .other).element(boundBy: 0).tap()
        element/*@START_MENU_TOKEN@*/.press(forDuration: 4.5);/*[[".tap()",".press(forDuration: 4.5);"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        element.children(matching: .textField).element.tap()
        
        let element2 = element.children(matching: .other).element(boundBy: 1)
        element2.children(matching: .textField).matching(identifier: "00").element(boundBy: 0).tap()
        element2.children(matching: .textField).matching(identifier: "00").element(boundBy: 1).tap()
        element2.children(matching: .textField).matching(identifier: "00").element(boundBy: 2).tap()
        element2.children(matching: .textField).matching(identifier: "00").element(boundBy: 3).tap()
        app.buttons["SEND"].tap()
        element3.children(matching: .other).element(boundBy: 1).tap()
        window.tap()
                
        
    }
    func testAlert() {
             
         let app = XCUIApplication()
         app.tabBars.buttons["More"].tap()
         
         let okButton = app.alerts["Error"].scrollViews.otherElements.buttons["OK"]
         okButton.tap()
         XCTAssertTrue(okButton.exists)
         XCTAssertTrue(app.alerts.element.staticTexts["Error"].exists)
     }
    func testDismissButton() {
        let app = XCUIApplication()
            app.tabBars.buttons["More"].tap()
            
        let dismissButton = app.buttons["Dismiss"]
        XCTAssertTrue(dismissButton.exists)
        }
    func testdSendButton() {
        let app = XCUIApplication()
            app.tabBars.buttons["More"].tap()
            
        let sendButton = app.buttons["SEND"]
        XCTAssertTrue(sendButton.exists)
        }
    func testdSettingButton() {
          let app = XCUIApplication()
          app.tabBars.buttons["More"].tap()
          let settingButton = app.buttons["Settings"]
              XCTAssertTrue(settingButton.exists)
          
      }
    func testForLogoLabel() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["More"].tap()
        
        let okButton = app.alerts["Error"].scrollViews.otherElements.buttons["OK"]
        okButton.tap()
        //let dismissButton = app.buttons["Dismiss"]
        okButton.tap()
        
        let openxcDemoAppStaticText = app.staticTexts["OpenXC Demo App"]
      XCTAssertTrue(openxcDemoAppStaticText.exists)
     
    }
}
