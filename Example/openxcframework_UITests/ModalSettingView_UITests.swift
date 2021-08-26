//
//  ModalSettingView_UITests.swift
//  openxcframework_UITests
//
//  Created by Ranjan, Kumar sahu (K.) on 02/09/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class ModalSettingView_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }


    func testDismissButton() {
          let app = XCUIApplication()
         app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
          let dissmissButton = app.buttons["Dismiss"]
              XCTAssertTrue(dissmissButton.exists)
          
      }
    func testForLogoLabel() {
        
        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let openxcDemoAppStaticText = app.staticTexts["OpenXC Demo App Settings"]
      XCTAssertTrue(openxcDemoAppStaticText.exists)
     
    }
    func testAboutButton() {
            let app = XCUIApplication()
           app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
           let aboutButton = app.buttons["About"]
                XCTAssertTrue(aboutButton.exists)
            
        }
    func testDataSourceButton() {
            let app = XCUIApplication()
           app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            let datasourceButton = app.buttons["Data Sources"]
                XCTAssertTrue(datasourceButton.exists)
            
        }
    func testRecordingButton() {
            let app = XCUIApplication()
           app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            let recordingButton = app.buttons["Recording"]
                XCTAssertTrue(recordingButton.exists)
            
        }
    func testNotificationButton() {
            let app = XCUIApplication()
           app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            let notificationButton = app.buttons["Notification"]
                XCTAssertTrue(notificationButton.exists)
            
        }
    func testOutputButton() {
            let app = XCUIApplication()
           app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            let outputButton =  app.buttons["Output"]
                XCTAssertTrue(outputButton.exists)
            
        }
    
}
