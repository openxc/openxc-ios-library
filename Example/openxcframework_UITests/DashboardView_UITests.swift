//
//  DashboardView_UITests.swift
//  openxcframework_UITests
//
//  Created by Ranjan, Kumar sahu (K.) on 24/08/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class DashboardView_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    func testSettingButton() {
          let app = XCUIApplication()
          app.tabBars.buttons["Dashboard"].tap()
          //let appView = DashboardViewController()
          let settingButton = app.buttons["Settings"]
              XCTAssertTrue(settingButton.exists)
          
      }
    func testForLogoLabel(){
        
        let app = XCUIApplication()
        app.tabBars.buttons["Dashboard"].tap()
        
        let okButton = app.alerts["Error"].scrollViews.otherElements.buttons["OK"]
        okButton.tap()
        let dismissButton = app.buttons["Dismiss"]
        okButton.tap()
        
        let openxcDemoAppStaticText = app.staticTexts["OpenXC Demo App"]
      XCTAssertTrue(openxcDemoAppStaticText.exists)
      XCTAssertTrue(dismissButton.exists)
      XCTAssertTrue(okButton.exists)
    }
    func testAlert() {
            
        let app = XCUIApplication()
        app.tabBars.buttons["Dashboard"].tap()
        
        let okButton = app.alerts["Error"].scrollViews.otherElements.buttons["OK"]
        okButton.tap()
        XCTAssertTrue(okButton.exists)
        XCTAssertTrue(app.alerts.element.staticTexts["Error"].exists)
    }
    func testEmptyTable(){
        let app = XCUIApplication()
            app.tabBars.buttons["Dashboard"].tap()
        
        let emptyListTable = app.tables["Empty list"]
               emptyListTable.swipeUp()
               emptyListTable.swipeDown()
               emptyListTable.tap()
          XCTAssertTrue(emptyListTable.exists)
    }

}
