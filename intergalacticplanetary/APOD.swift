//
//  APOD.swift
//  intergalacticplanetary
//
//  Created by Kenny Schlagel on 2/3/16.
//  Copyright © 2016 Kenny Schlagel. All rights reserved.
//

import Foundation
import UIKit

// MARK: Typealias

typealias APODSResult = ([APOD]?, ErrorType?) -> Void
typealias APODResult = (APOD?, ErrorType?) -> Void

class APOD: NSObject, APODDataSource {
  var itemId: String?
  var date: String?
  var photoUrl: NSURL?
  var title: String?
  var explanation: String?
  var copyright: String?
  var error: String = ""
  
  static let itemIdKey = "itemId"
  static let datetKey = "date"
  static let photoUrlKey = "photoUrl"
  static let titleKey = "title"
  static let explanationKey = "explanation"
  static let copyrightKey = "copyright"
  
  init?(values: AnyObject, forUrl: NSURL) {
    itemId = forUrl.absoluteString
    
    guard let url = values["url"] as? String,
      castedUrl = NSURL(string: url),
      dateIn = values["date"] as? String,
      name = values["title"] as? String,
      exp = values["explanation"] as? String,
      type = values["media_type"] as? String where type == "image" else {
        return
    }
    photoUrl = castedUrl
    title = name
    date = dateIn
    explanation = exp
    if let copy = values["copyright"] as? String {
      copyright =  copy
    } else {
      copyright = "NASA"
    }
    
    // we want the hd image
    if let hd = values["hdurl"] as? String, castedHDUrl = NSURL(string: hd) {
      photoUrl = castedHDUrl
    }
  }
  
  init(backup: APODBackup) {
    itemId = backup.itemId
    date = backup.date
    photoUrl = backup.photoUrl
    title = backup.title
    explanation = backup.explanation
    copyright = backup.copyright
    error = backup.error
  }
  

  
  // MARK: NSCoder methods
  
  @objc required init?(coder aDecoder: NSCoder) {
    guard let decodedItemId = aDecoder.decodeObjectForKey(APOD.itemIdKey) as? String,
      let decodedDate = aDecoder.decodeObjectForKey(APOD.datetKey) as? String,
      let decodedExplanation = aDecoder.decodeObjectForKey(APOD.explanationKey) as? String,
      let decodedPhotoUrl = aDecoder.decodeObjectForKey(APOD.photoUrlKey) as? NSURL,
      let decodedTitle = aDecoder.decodeObjectForKey(APOD.titleKey) as? String,
      let decodedCopyright = aDecoder.decodeObjectForKey(APOD.copyrightKey) as? String else {
        return
    }
    itemId = decodedItemId
    date = decodedDate
    photoUrl = decodedPhotoUrl
    title = decodedTitle
    explanation = decodedExplanation
    copyright = decodedCopyright
  }
  
  @objc func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(itemId, forKey: APOD.itemIdKey)
    aCoder.encodeObject(date, forKey: APOD.datetKey)
    aCoder.encodeObject(photoUrl, forKey: APOD.photoUrlKey)
    aCoder.encodeObject(title, forKey: APOD.titleKey)
    aCoder.encodeObject(explanation, forKey: APOD.explanationKey)
    aCoder.encodeObject(copyright, forKey: APOD.copyrightKey)
  }
  
  // register your backup APOD here
  class func getBackup() -> APODBackup {
    return earth()
  }
  
  class func getBackupImage() -> UIImage {
    return APOD.getBackup().image
  }
  // MARK: Get APOD Methods
  
  // get multiple APODS - not used
  class func getAPODsForFeed(completion: APODSResult) {
    let router = APODRouter()
    let today = NSDate()
    
    guard let url = router.createURLWithComponentsForDate(today) else {
      completion(nil, APODServiceError.URLParsing)
      return
    }
    
    NASAClient.sharedInstance.getDataFromUrl(url) { (result, error) in
      guard error == nil else {
        completion(nil, error)
        return
      }
      if let result = result as AnyObject?, apod = APOD(values: result, forUrl: url) {
        var apods = [APOD]()
        apods.append(apod)
        completion(apods, nil)
      } else {
        completion(nil, APODServiceError.JSONStructure)
      }
    }
  }
  
  // get a single APOD
  class func getAPODForDate(date date: NSDate, completion: APODResult) {
    let router = APODRouter()

    guard let url = router.createURLWithComponentsForDate(date) else {
      completion(nil, APODServiceError.URLParsing)
      return
    }
    
    NASAClient.sharedInstance.getDataFromUrl(url) { (result, error) in
      guard error == nil else {
        completion(nil, error)
        return
      }
      if let result = result as AnyObject? {
        let apod = APOD(values: result, forUrl: url)
        completion(apod, nil)
      } else {
        completion(nil, APODServiceError.JSONStructure)
      }
    }
  }
}

// MARK: equatable
func == (lhs: APOD, rhs: APOD) -> Bool {
  return lhs.itemId == rhs.itemId
}

// MARK: Error Enums
enum APODServiceError: String, ErrorType {
  case NotImplemented = "We haven't added this feature yet"
  case URLParsing = "There was a problem parsing the URL"
  case JSONStructure = "APOD service returned something different than what we expected"
}