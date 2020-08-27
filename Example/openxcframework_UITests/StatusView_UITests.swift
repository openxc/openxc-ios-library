//
//  openxcframework_UITests.swift
//  openxcframework_UITests
//
//  Created by Ranjan, Kumar sahu (K.) on 05/08/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest


class StatusView_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
          XCUIApplication().launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    func testdSettingButton() {
          let app = XCUIApplication()
              app.launch()
          
          let settingButton = app.buttons["SettingButton"]
              XCTAssertTrue(settingButton.exists)
          
      }
    func testSearchForBleButton() {
        let app = XCUIApplication()
        app.launch()
        
        let searchButton = app.buttons["SearchForBle"]
            searchButton.tap()
            XCTAssertTrue(searchButton.exists)
    }

   
    func testForActiveConnectionLabel()  {
        
        let app = XCUIApplication()
            app.launch()
        
        let activeConnectionStateLabel = app.staticTexts["ConnectionState"]
               XCTAssertTrue(activeConnectionStateLabel.exists)
               XCTAssertEqual("---",activeConnectionStateLabel.label )
        
        
       let activeConnectionLabel = app.staticTexts["ActiveConnection"]
       XCTAssertTrue(activeConnectionLabel.exists)
       
    }
    
    func testForMessageReceivedLabel()  {
        
        let app = XCUIApplication()
            app.launch()
        
        let messagesCounteLabel = app.staticTexts["MessagesCount"]
               XCTAssertTrue(messagesCounteLabel.exists)
               XCTAssertEqual("---",messagesCounteLabel.label )
        
        
       let messagesReceivedLabel = app.staticTexts["MessagesReceived"]
       XCTAssertTrue(messagesReceivedLabel.exists)
       
    }
    func testForAverageMessageLabel()  {
        
        let app = XCUIApplication()
            app.launch()
        
        let messageSizeLabel = app.staticTexts["MessageSize"]
               XCTAssertTrue(messageSizeLabel.exists)
               XCTAssertEqual("---",messageSizeLabel.label )
        
        
       let AverageMessageLabel = app.staticTexts["AverageMessageSize"]
       XCTAssertTrue(AverageMessageLabel.exists)
       
    }
    func testForVersionLabel()  {
        
        let app = XCUIApplication()
            app.launch()
        
        let versionNumberLabel = app.staticTexts["VersionNumber"]
               XCTAssertTrue(versionNumberLabel.exists)
               XCTAssertEqual("---",versionNumberLabel.label )
        
        
       let versionLabel = app.staticTexts["Version"]
       XCTAssertTrue(versionLabel.exists)
       
    }
    func testForDeviceIdLabel()  {
        
        let app = XCUIApplication()
            app.launch()
        
        let deviceNumberLabel = app.staticTexts["DeviceNumber"]
               XCTAssertTrue(deviceNumberLabel.exists)
               XCTAssertEqual("---",deviceNumberLabel.label )
        
        
       let deviceIdLabel = app.staticTexts["DeviceId"]
       XCTAssertTrue(deviceIdLabel.exists)
       
    }
    func testForPlatformLabel()  {
         
         let app = XCUIApplication()
             app.launch()
         
         let platformNumberLabel = app.staticTexts["PlatformNumber"]
                XCTAssertTrue(platformNumberLabel.exists)
                XCTAssertEqual("---",platformNumberLabel.label )
         
         
        let platformLabel = app.staticTexts["Platform"]
        XCTAssertTrue(platformLabel.exists)
        
     }
    func testForThroughputLabel()  {
           
           let app = XCUIApplication()
               app.launch()
           
           let throughputAverageLabel = app.staticTexts["ThroughputAverage"]
                  XCTAssertTrue(throughputAverageLabel.exists)
                  XCTAssertEqual("---",throughputAverageLabel.label )
           
           
          let throughputLabel = app.staticTexts["Throughput"]
          XCTAssertTrue(throughputLabel.exists)
          
       }
    
    func testForLogoLabel(){
        
        let app = XCUIApplication()
            app.launch()
        
        let logoLabel = app.staticTexts["OpenxcLogo"]
               XCTAssertTrue(logoLabel.exists)
               
    }
//    func testEmptyTable() {
//          let app = XCUIApplication()
//              app.launch()
//
//          let emptyListTable = app.tables["Empty list"]
//            XCTAssertTrue(emptyListTable.exists)
//      }
}
