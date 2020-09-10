//
//  DiagnosticView_UITests.swift
//  openxcframework_UITests
//
//  Created by Ranjan, Kumar sahu (K.) on 08/09/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class DiagnosticView_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    func testForLogoLabel(){

         let app = XCUIApplication()
         app.tabBars.buttons["Diagnostic"].tap()
        
        let logoLabel =  app.staticTexts["OpenXC Demo App"]
               XCTAssertTrue(logoLabel.exists)
               
    }
    func testdSettingButton() {
           let app = XCUIApplication()
           app.tabBars.buttons["Diagnostic"].tap()
          
          let settingButton = app.buttons["SettingButton"]
              XCTAssertTrue(settingButton.exists)
          
      }
    func testSearchForBleButton() {
        let app = XCUIApplication()
        app.tabBars.buttons["Diagnostic"].tap()
        
        let sendButton = app.buttons["SEND"]
            sendButton.tap()
            XCTAssertTrue(sendButton.exists)
    }
    func testAlert() {
            
       let app = XCUIApplication()
        app.tabBars.buttons["Diagnostic"].tap()
        
        let okButton = app.alerts["Error"].scrollViews.otherElements.buttons["OK"]
        okButton.tap()
        XCTAssertTrue(okButton.exists)
        XCTAssertTrue(app.alerts.element.staticTexts["Error"].exists)
    }
    func testBusLabele() {
           
           let app = XCUIApplication()
           app.tabBars.buttons["Diagnostic"].tap()
           let labelBus = app.staticTexts["Bus"]
           XCTAssertTrue(labelBus.exists)
     

       }
    func testMessageIdLabele() {
             
             let app = XCUIApplication()
             app.tabBars.buttons["Diagnostic"].tap()
             let labelMessageId =  app.staticTexts["Message ID (hex)"]
             XCTAssertTrue(labelMessageId.exists)
       

         }
    func testModeLabele() {
             
             let app = XCUIApplication()
             app.tabBars.buttons["Diagnostic"].tap()
             let labelMode =  app.staticTexts["Mode (hex)"]
             XCTAssertTrue(labelMode.exists)
    }
    func testPidLabele() {
             
             let app = XCUIApplication()
             app.tabBars.buttons["Diagnostic"].tap()
             let labelPid =  app.staticTexts["PID (hex,optional)"]
             XCTAssertTrue(labelPid.exists)
       

         }
    func testPayloadLabele() {
             
             let app = XCUIApplication()
             app.tabBars.buttons["Diagnostic"].tap()
             let labelPayload =  app.staticTexts["Payload"]
             XCTAssertTrue(labelPayload.exists)


         }
    func testLastRequestLabel() {
        let app = XCUIApplication()
            app.tabBars.buttons["Diagnostic"].tap()
            let labelLastRequest =  app.staticTexts["Last Request"]
            XCTAssertTrue(labelLastRequest.exists)
        
    }
    func testResponseLabel() {
           let app = XCUIApplication()
               app.tabBars.buttons["Diagnostic"].tap()
               let labelresponse =  app.staticTexts["Responses"]
               XCTAssertTrue(labelresponse.exists)
           
       }
    func testResponseData() {
        let app = XCUIApplication()
            app.tabBars.buttons["Diagnostic"].tap()
            let labelResponseData =  app.textViews.staticTexts["------"]
            XCTAssertTrue(labelResponseData.exists)
        
    }
    func testTextField() {
        let app = XCUIApplication()
        app.tabBars.buttons["Diagnostic"].tap()
        
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
        element.tap()
        let textField0 = element.children(matching: .textField).element(boundBy: 0)
        let textField1 = element.children(matching: .textField).element(boundBy: 1)
        let textField2 = element.children(matching: .textField).element(boundBy: 2)
        let textField3 =  element.children(matching: .textField).element(boundBy: 3)
        
        
         XCTAssertTrue(textField0.exists)
         XCTAssertTrue(textField1.exists)
         XCTAssertTrue(textField2.exists)
         XCTAssertTrue(textField3.exists)

    }
    
}
