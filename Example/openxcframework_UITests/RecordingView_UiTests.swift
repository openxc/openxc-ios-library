//
//  RecordingView_UiTests.swift
//  openxcframework_UITests
//
//  Created by Ranjan, Kumar sahu (K.) on 11/09/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class RecordingView_UiTests: XCTestCase {

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
          app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
          app.buttons["Recording"].tap()
         
         let logoLabel =  app.staticTexts["Recording"]
                XCTAssertTrue(logoLabel.exists)
                
     }
     func testDismissButton() {
           let app = XCUIApplication()
            app.buttons["SettingButton"].tap()
            app.buttons["Recording"].tap()
           
           let dismissButton = app.buttons["Dismiss"]
               XCTAssertTrue(dismissButton.exists)
           
       }
    func testForRecordTraceLabel() {
          let app = XCUIApplication()
           app.buttons["SettingButton"].tap()
           app.buttons["Recording"].tap()
          
          let recordTraceLabel = app.staticTexts["Record Trace"]
              XCTAssertTrue(recordTraceLabel.exists)
              
          }
    func testForRecordDataFileLabel() {
          let app = XCUIApplication()
           app.buttons["SettingButton"].tap()
           app.buttons["Recording"].tap()
          
          let recordTraceFile = app.staticTexts["Record the vehicle data stream to a file"]
              XCTAssertTrue(recordTraceFile.exists)
              
          }
    
    func testForOutputDweetLabel() {
        let app = XCUIApplication()
         app.buttons["SettingButton"].tap()
         app.buttons["Recording"].tap()
        
        let outputDweet = app.staticTexts["Output to Dweet.io"]
            XCTAssertTrue(outputDweet.exists)
        
    }
    func testForDweetOutputLabel() {
        let app = XCUIApplication()
         app.buttons["SettingButton"].tap()
         app.buttons["Recording"].tap()
        
        let outputDweetStream = app.staticTexts["Output the measurement vehicle data stream to dweet.io"]
            XCTAssertTrue(outputDweetStream.exists)
        
    }
    func testForDweetNameLabel() {
        let app = XCUIApplication()
         app.buttons["SettingButton"].tap()
         app.buttons["Recording"].tap()
        
        let dweetFileName = app.staticTexts["dweet name"]
            XCTAssertTrue(dweetFileName.exists)
        
    }
    
    func testForUploadLabel() {
          let app = XCUIApplication()
           app.buttons["SettingButton"].tap()
           app.buttons["Recording"].tap()
          
          let uploadTraceLabel = app.staticTexts["Upload Trace"]
              XCTAssertTrue(uploadTraceLabel.exists)
          
      }
    func testForTargetUrlLabel() {
        let app = XCUIApplication()
         app.buttons["SettingButton"].tap()
         app.buttons["Recording"].tap()
        
        let targetUrlLabel = app.staticTexts["Target URL"]
            XCTAssertTrue(targetUrlLabel.exists)
        
    }
    func testForDeviceIdLabel() {
          let app = XCUIApplication()
           app.buttons["SettingButton"].tap()
           app.buttons["Recording"].tap()
          
          let deviceIdLabel = app.staticTexts["Device_id_not_available"]
              XCTAssertTrue(deviceIdLabel.exists)
          
      }
    func testForDeviceIdValueLabel() {
            let app = XCUIApplication()
             app.buttons["SettingButton"].tap()
             app.buttons["Recording"].tap()
            
            let deviceIdValueLabel = app.staticTexts["1C90443F-22A5-4520-AB36-F35E92CB48D6"]
                XCTAssertTrue(deviceIdValueLabel.exists)
            
        }
    func testForDweetTextField() {
          let app = XCUIApplication()
           app.buttons["SettingButton"].tap()
           app.buttons["Recording"].tap()
          
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1)
           element.children(matching: .textField).element(boundBy: 0).tap()
            let dweetNameTextField  = app.textFields["Dweet name"]
         
              XCTAssertTrue(dweetNameTextField.exists)
          
      }
    


}
