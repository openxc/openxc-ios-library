//
//  openxcframework_UITests.swift
//  openxcframework_UITests
//
//  Created by Ranjan, Kumar sahu (K.) on 05/08/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest

class openxcframework_UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    func testSerchBleButton() {
        let app = XCUIApplication()
        app.launch()
        
        let searchButton = app.buttons["SearchForBle"]
            searchButton.tap()
            XCTAssertTrue(searchButton.exists)
        
        let activeConnectionLabel = app.staticTexts["ActiveConnection"]
        XCTAssertTrue(activeConnectionLabel.exists)
        XCTAssertEqual("---",activeConnectionLabel.label )
        
        
    }
}
