//
//  intergalacticplanetaryTests.swift
//  intergalacticplanetaryTests
//
//  Created by Kenny Schlagel on 2/3/16.
//  Copyright © 2016 Kenny Schlagel. All rights reserved.
//

import XCTest
@testable import intergalacticplanetary

class intergalacticplanetaryTests: XCTestCase {
  let url = NSURL(string: "info.nduktlabs.apod")
  let goodJSON: AnyObject = [
    "date": "2016-02-13",
    "explanation": "Tracks lead to a small robot perched near the top of this bright little planet. Of course, the planet is really the Moon. The robot is the desk-sized Yutu rover, leaving its looming Chang'e 3 lander after a after a mid-December 2013 touch down in the northern Mare Imbrium. The little planet projection is a digitally warped and stitched mosaic of images from the lander's terrain camera covering 360 by 180 degrees. Ultimately traveling over 100 meters, Yutu came to a halt in January 2014. The lander's instruments are still working though, after more than two years on the lunar surface. Meanwhile, an interactive panoramic version of this little planet is available here.",
    "hdurl": "http://apod.nasa.gov/apod/image/1602/lunar-panorama-change-3-lander-2013-12-17.jpg",
    "media_type": "image",
    "service_version": "v1",
    "title": "Yutu on a Little Planet",
    "url": "http://apod.nasa.gov/apod/image/1602/lunar-panorama-change-3-lander-2013-12-17re.jpg"
  ]
  // media_type should be image
  let badJSONmediatype: AnyObject = [
    "date": "2016-02-13",
    "explanation": "Tracks lead to a small robot perched near the top of this bright little planet. Of course, the planet is really the Moon. The robot is the desk-sized Yutu rover, leaving its looming Chang'e 3 lander after a after a mid-December 2013 touch down in the northern Mare Imbrium. The little planet projection is a digitally warped and stitched mosaic of images from the lander's terrain camera covering 360 by 180 degrees. Ultimately traveling over 100 meters, Yutu came to a halt in January 2014. The lander's instruments are still working though, after more than two years on the lunar surface. Meanwhile, an interactive panoramic version of this little planet is available here.",
    "hdurl": "http://apod.nasa.gov/apod/image/1602/lunar-panorama-change-3-lander-2013-12-17.jpg",
    "media_type": "media",
    "service_version": "v1",
    "title": "Yutu on a Little Planet",
    "url": "http://apod.nasa.gov/apod/image/1602/lunar-panorama-change-3-lander-2013-12-17re.jpg"
  ]
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
  
  
  func testJSONisvalid() {
    let apod = APOD(values: goodJSON, forUrl: url!)
    XCTAssertNotNil(apod?.photoUrl)
  }
  
  func testJSONisnotvalid() {
    let apod = APOD(values: badJSONmediatype, forUrl: url!)
    XCTAssertNil(apod?.photoUrl)
  }
  
  func testURLisHDWhenHDExists() {
    let hdurl = NSURL(string: "http://apod.nasa.gov/apod/image/1602/lunar-panorama-change-3-lander-2013-12-17.jpg")
    let apod = APOD(values: goodJSON, forUrl: url!)
    XCTAssertEqual(hdurl, apod?.photoUrl)
  }
  
  func testCanCreateBackup() {
    let apod = APOD(backup: APOD.getBackup())
    XCTAssertNotNil(apod.photoUrl)
  }
  
  func testBackupHasImage() {
    let image = APOD.getBackupImage()
    XCTAssertNotNil(image)
  }
  
  func testValidNetworkCallForAPOD() {
    // this date had a valid APOD
    let dateString = "2016-02-13"
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let date = dateFormatter.dateFromString(dateString)
    let expectation = expectationWithDescription("Get todays APOD meta data")
    APOD.getAPODForDate(date: date!) { (apod, error) in
      XCTAssertNotNil(apod, "we should have some apod data")
      XCTAssertNil(error, "error should be nil")
      if let apod = apod?.photoUrl {
        expectation.fulfill()
      } else {
        XCTFail("Could not load the apod data")
      }
    }
    waitForExpectationsWithTimeout(3.0, handler: nil)
  }
  
  func testBadNetworkCallForAPOD() {
    // this date was a video and had invalid APOD data
    let dateString = "2016-02-12"
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    let date = dateFormatter.dateFromString(dateString)
    let expectation = expectationWithDescription("Get todays APOD meta data")
    APOD.getAPODForDate(date: date!) { (apod, error) in
      XCTAssertNotNil(apod, "we should have some apod data")
      XCTAssertNil(error, "error should be nil")
      if let apod = apod?.photoUrl {
        XCTFail("We had good data actually")
      } else {
        expectation.fulfill()

      }
    }
    waitForExpectationsWithTimeout(2.0, handler: nil)
  }
  
  func testAPODRouter() {
    let router = APODRouter()
    let date = NSDate()
    let url = router.createURLWithComponentsForDate(date)
    XCTAssertNotNil(url)
    
    let components = NSURLComponents(URL: url!, resolvingAgainstBaseURL: false)
    XCTAssertNotNil(components?.queryItems)
    
    let queryItems = components!.queryItems!
    
    let expectedHDQueryItem = NSURLQueryItem(name: "hd", value: "true")
    XCTAssertTrue(queryItems.contains(expectedHDQueryItem))
    
    let today = NSDate()
    let expectedDateQueryItem = NSURLQueryItem(name: "date", value: router.dateToString(today))
    XCTAssertTrue(queryItems.contains(expectedDateQueryItem))
  }
}

// http://nshipster.com/xctestcase/