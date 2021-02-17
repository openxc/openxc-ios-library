//
//  DataSourceView_UITests.swift
//  openxcframework_UITests
//
//  Created by Ranjan, Kumar sahu (K.) on 11/09/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class DataSourceView_UITests: XCTestCase {

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
        app.buttons["Data Sources"].tap()
        
        let logoLabel =  app.staticTexts["Data Sources"]
            XCTAssertTrue(logoLabel.exists)
               
    }
    func testDismissButton() {
     
        let app = XCUIApplication()
         app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
         app.buttons["Data Sources"].tap()
          
          let dismissButton = app.buttons["Dismiss"]
              XCTAssertTrue(dismissButton.exists)
          
      }
    func testVehicleInterFaceButton() {
      
         let app = XCUIApplication()
          app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
          app.buttons["Data Sources"].tap()
           
          let vehicleInterfaceButton = app.buttons["Vehicle Interface"]
              vehicleInterfaceButton.tap()
              XCTAssertTrue(vehicleInterfaceButton.exists)
           
       }
    func testradioButtonButton() {
    
       let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
         
       let vehicleInterfaceButton = app.buttons["Vehicle Interface"]
        vehicleInterfaceButton.tap()
        
        let element3 = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
        let element2 = element3.children(matching: .other).element(boundBy: 0).children(matching: .other).element
        let radiobtnWhiteUncheckedButton = element2.children(matching: .button).matching(identifier: "RadioBtn white Unchecked").element(boundBy: 1)
            radiobtnWhiteUncheckedButton.tap()
            XCTAssertTrue(radiobtnWhiteUncheckedButton.exists)
         
     }
    func testVehicleInterFaceCancelButton() {
        
           let app = XCUIApplication()
            app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
            app.buttons["Data Sources"].tap()
             let vehicleInterfaceButton = app.buttons["Vehicle Interface"]
                    vehicleInterfaceButton.tap()
                    
            let element3 = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element
            let element2 = element3.children(matching: .other).element(boundBy: 0).children(matching: .other).element
            let radiobtnWhiteUncheckedButton = element2.children(matching: .button).matching(identifier: "RadioBtn white Unchecked").element(boundBy: 1)
            radiobtnWhiteUncheckedButton.tap()
                    
                    
            let cancelButton = app.buttons["Cancel"]
                cancelButton.tap()
                XCTAssertTrue(cancelButton.exists)
             
         }
    
    func testForPlaybackTraceLabel(){

           let app = XCUIApplication()
           app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
           app.buttons["Data Sources"].tap()
           
          let playbackTraceStaticText = app.staticTexts["Playback Trace"]
              XCTAssertTrue(playbackTraceStaticText.exists)
                  
       }
    func testForDisableTraceLabel(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let disableTraceLabel = app.staticTexts["Disable trace loop"]
           XCTAssertTrue(disableTraceLabel.exists)
               
    }
    func testForStopTracePlayingLabel(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let stopTracePlayingLabel = app.staticTexts["Stop playing the trace file in loop"]
           XCTAssertTrue(stopTracePlayingLabel.exists)
               
    }
    func testForNetworDeviceLabel(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let networkDeviceLabel = app.staticTexts["Use a network device "]
           XCTAssertTrue(networkDeviceLabel.exists)
               
    }
    func testForNetworHostLabel(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let networkHostAdressLabel = app.staticTexts["Network host address"]
           XCTAssertTrue(networkHostAdressLabel.exists)
               
    }
    func testForNetworPortLabel(){

          let app = XCUIApplication()
          app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
          app.buttons["Data Sources"].tap()
          
         let networkPortAdressLabel = app.staticTexts["Network port"]
             XCTAssertTrue(networkPortAdressLabel.exists)
                 
      }
    func testForUseBuiltInGPSLabel(){

           let app = XCUIApplication()
           app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
           app.buttons["Data Sources"].tap()
           
          let builtInGPSLabel = app.staticTexts["Use built-in GPS"]
              XCTAssertTrue(builtInGPSLabel.exists)
                  
       }
    func testForGPSReciverLabel(){

           let app = XCUIApplication()
           app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
           app.buttons["Data Sources"].tap()
           
          let locationReceeiverLabel = app.staticTexts["For vehicles without a GPS receiver, send the host's GPS Location"]
              XCTAssertTrue(locationReceeiverLabel.exists)
                  
       }
    func testForBleAutoConnectLabel(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let bleAutoConnectLabel = app.staticTexts["BLE Autoconnect"]
           XCTAssertTrue(bleAutoConnectLabel.exists)
               
    }
    func testForAutoConnectDeviceLabel(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let autoConnectDeviceLabel = app.staticTexts["Autoconnect to first discovered VI"]
           XCTAssertTrue(autoConnectDeviceLabel.exists)
               
    }
    func testForProtobufModeLabel(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let protobufModeLabel = app.staticTexts["Protobuf Mode"]
           XCTAssertTrue(protobufModeLabel.exists)
               
    }
    func testForChangeModeLabel(){

          let app = XCUIApplication()
          app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
          app.buttons["Data Sources"].tap()
          
         let changeModeLabel = app.staticTexts["Configure the app to receive data from a VI set to Protobuf data format (instead of JSON)"]
             XCTAssertTrue(changeModeLabel.exists)
                 
      }
    func testForThroughPutLabel(){

          let app = XCUIApplication()
          app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
          app.buttons["Data Sources"].tap()
          
         let throughputLabel = app.staticTexts["Throughput Calculator"]
             XCTAssertTrue(throughputLabel.exists)
                 
      }
    func testForThroughPutUnitLabel(){

           let app = XCUIApplication()
           app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
           app.buttons["Data Sources"].tap()
           
          let throughputUnitLabel = app.staticTexts["Calculate throughput(Bytes/sec)"]
              XCTAssertTrue(throughputUnitLabel.exists)
                  
       }
    func testForPhoneSensorLabel(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let phoneSensorLabel = app.staticTexts["Include Phone Sensor Data"]
           XCTAssertTrue(phoneSensorLabel.exists)
               
    }
    func testForPhoneSensorDataLabel(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let phoneSensorDataLabel = app.staticTexts["Phone Sensor data will be displayed in the dashboard"]
           XCTAssertTrue(phoneSensorDataLabel.exists)
               
    }
    func testForUrlPortTextField(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let urlPortTextField =  app.textFields["50001"]
           XCTAssertTrue(urlPortTextField.exists)
               
    }
    func testForUrlHostTextField(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let urlHostTextField = app.textFields["0.0.0.0"]
           XCTAssertTrue(urlHostTextField.exists)
               
    }
    func testTraceFileNameTextField(){

        let app = XCUIApplication()
        app/*@START_MENU_TOKEN@*/.buttons["SettingButton"]/*[[".buttons[\"Settings\"]",".buttons[\"SettingButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Data Sources"].tap()
        
       let traceTextFieldName = app.textFields["File Name"]
           XCTAssertTrue(traceTextFieldName.exists)
               
    }
    
    
}
