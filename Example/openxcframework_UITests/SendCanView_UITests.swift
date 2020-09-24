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
    func testAlert() {
             
         let app = XCUIApplication()
         app.tabBars.buttons["More"].tap()
         app.tables/*@START_MENU_TOKEN@*/.staticTexts["Send CAN"]/*[[".cells.staticTexts[\"Send CAN\"]",".staticTexts[\"Send CAN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
         let okButton = app.alerts["Error"].scrollViews.otherElements.buttons["OK"]
         okButton.tap()
         XCTAssertTrue(okButton.exists)
         XCTAssertTrue(app.alerts.element.staticTexts["Error"].exists)
     }
 
    func testSendButton() {
        let app = XCUIApplication()
            app.tabBars.buttons["More"].tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Send CAN"]/*[[".cells.staticTexts[\"Send CAN\"]",".staticTexts[\"Send CAN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            
        let sendButton = app.buttons["SEND"]
        XCTAssertTrue(sendButton.exists)
        }
    func testSettingButton() {
          let app = XCUIApplication()
          app.tabBars.buttons["More"].tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Send CAN"]/*[[".cells.staticTexts[\"Send CAN\"]",".staticTexts[\"Send CAN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
          let settingButton = app.buttons["Settings"]
              XCTAssertTrue(settingButton.exists)
          
      }
    func testForLogoLabel() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["More"].tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Send CAN"]/*[[".cells.staticTexts[\"Send CAN\"]",".staticTexts[\"Send CAN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let okButton = app.alerts["Error"].scrollViews.otherElements.buttons["OK"]
        //let dismissButton = app.buttons["Dismiss"]
        okButton.tap()
        
        let openxcDemoAppStaticText = app.staticTexts["OpenXC Demo App"]
      XCTAssertTrue(openxcDemoAppStaticText.exists)
     
    }
    
    func testBusLabele() {
        
        let app = XCUIApplication()
        app.tabBars.buttons["More"].tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Send CAN"]/*[[".cells.staticTexts[\"Send CAN\"]",".staticTexts[\"Send CAN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let labelBus = app.staticTexts["Bus"]
        XCTAssertTrue(labelBus.exists)
  

    }
    func testTextField() {
        let app = XCUIApplication()
            app.tabBars.buttons["More"].tap()
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["Send CAN"]/*[[".cells.staticTexts[\"Send CAN\"]",".staticTexts[\"Send CAN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
            element.tap()
            let textField = element.children(matching: .textField).element
            textField.tap()
            XCTAssertTrue(textField.exists)
    }
    func testSentMessageLabel() {
        let app = XCUIApplication()
            app.tabBars.buttons["More"].tap()
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["Send CAN"]/*[[".cells.staticTexts[\"Send CAN\"]",".staticTexts[\"Send CAN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
              let labelSentMessage = app.staticTexts["Sent Messages"]
              XCTAssertTrue(labelSentMessage.exists)
    }
    func testPayloadLabel() {
        let app = XCUIApplication()
        app.tabBars.buttons["More"].tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Send CAN"]/*[[".cells.staticTexts[\"Send CAN\"]",".staticTexts[\"Send CAN\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        let payloadHexStaticText = app.staticTexts["Payload (hex)"]
         XCTAssertTrue(payloadHexStaticText.exists)
    }
}

