//
//  NotificationView_UITests.swift
//  openxcframework_UITests
//
//  Created by Ranjan, Kumar sahu (K.) on 02/09/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class NotificationView_UITests: XCTestCase {

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
         app.buttons["Notification"].tap()
          let dissmissButton = app.buttons["Dismiss"]
              XCTAssertTrue(dissmissButton.exists)
          
      }
    func testForNotificationLabel() {
        
        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Notification"].tap()
        
        let openxcDemoAppStaticText = app.staticTexts["Notification"]
      XCTAssertTrue(openxcDemoAppStaticText.exists)
     
    }
    func testForPowerDropLabel() {
        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
         app.buttons["Notification"].tap()
        let powerDropStaticText = app.staticTexts["Power Drop"]
        XCTAssertTrue(powerDropStaticText.exists)
    }
    
    func testNetworkDropLabel() {
        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Notification"].tap()
        let networkDropStaticText = app.staticTexts["Network Drop"]
         XCTAssertTrue(networkDropStaticText.exists)
    }
    

}
