//
//  CommandView_UITests.swift
//  openxcframework_UITests
//
//  Created by Ranjan, Kumar sahu (K.) on 08/09/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class CommandView_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testAlertMessage () {
        
       let app = XCUIApplication()
       app.tabBars.buttons["More"].tap()
       app.tables/*@START_MENU_TOKEN@*/.staticTexts["Commands"]/*[[".cells.staticTexts[\"Commands\"]",".staticTexts[\"Commands\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let okButton = app.alerts["Error"].scrollViews.otherElements.buttons["OK"]
        okButton.tap()
        XCTAssertTrue(okButton.exists)
        XCTAssertTrue(app.alerts.element.staticTexts["Error"].exists)
    
    }
    
    func testForLogoLabel(){
        
         let app = XCUIApplication()
               app.tabBars.buttons["More"].tap()
               app.tables/*@START_MENU_TOKEN@*/.staticTexts["Commands"]/*[[".cells.staticTexts[\"Commands\"]",".staticTexts[\"Commands\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let logoLabel =  app.staticTexts["OpenXC Demo App"]
               XCTAssertTrue(logoLabel.exists)
               
    }
    func testSettingButton() {
        let app = XCUIApplication()
            app.tabBars.buttons["More"].tap()
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["Commands"]/*[[".cells.staticTexts[\"Commands\"]",".staticTexts[\"Commands\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
          
          let settingButton = app.buttons["Settings"]
              XCTAssertTrue(settingButton.exists)
          
      }
    func testSendButton() {
       let app = XCUIApplication()
               app.tabBars.buttons["More"].tap()
               app.tables/*@START_MENU_TOKEN@*/.staticTexts["Commands"]/*[[".cells.staticTexts[\"Commands\"]",".staticTexts[\"Commands\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        let sendButton = app.buttons["Send"]
            sendButton.tap()
            XCTAssertTrue(sendButton.exists)
    }
    func testSelectComandLabel() {
        let app = XCUIApplication()
            app.tabBars.buttons["More"].tap()
            app.tables/*@START_MENU_TOKEN@*/.staticTexts["Commands"]/*[[".cells.staticTexts[\"Commands\"]",".staticTexts[\"Commands\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
               
        let selectCommandLabel =  app.staticTexts["Select a command"]
            XCTAssertTrue(selectCommandLabel.exists)
                      
        
    }
    func testComandResponseLabel() {
          let app = XCUIApplication()
              app.tabBars.buttons["More"].tap()
              app.tables/*@START_MENU_TOKEN@*/.staticTexts["Commands"]/*[[".cells.staticTexts[\"Commands\"]",".staticTexts[\"Commands\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                 
          let commandResponseLabel =   app.staticTexts["Command Response"]
              XCTAssertTrue(commandResponseLabel.exists)
                        
          
      }
    func testComandResponseDataLabel() {
            let app = XCUIApplication()
                app.tabBars.buttons["More"].tap()
                app.tables/*@START_MENU_TOKEN@*/.staticTexts["Commands"]/*[[".cells.staticTexts[\"Commands\"]",".staticTexts[\"Commands\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
                   
            let commandResponseDataLabel =    app.staticTexts["---"]
                XCTAssertTrue(commandResponseDataLabel.exists)
                          
            
        }

}
