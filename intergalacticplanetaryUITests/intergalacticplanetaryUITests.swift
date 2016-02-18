//
//  intergalacticplanetaryUITests.swift
//  intergalacticplanetaryUITests
//
//  Created by Kenny Schlagel on 2/18/16.
//  Copyright © 2016 Kenny Schlagel. All rights reserved.
//

import XCTest

class intergalacticplanetaryUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStellarButtonHidesWhenEarthIsUsed() {
      let app = XCUIApplication()
      let stellarBUtton = app.buttons["stellar"]
      let stellarButtonIsHidden = stellarBUtton.frame.size.width == 0 || stellarBUtton.frame.size.height == 0
      let stellarButtonIsNotHidden = stellarBUtton.frame.size.width > 0 || stellarBUtton.frame.size.height > 0

      if app.staticTexts["Blue Marble Earth from Suomi NPP"].exists {
        XCTAssertTrue(stellarButtonIsHidden)
      } else {
        XCTAssertTrue(stellarButtonIsNotHidden)
      }
    }
    
}
