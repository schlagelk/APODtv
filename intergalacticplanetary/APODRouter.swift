//
//  APODRouter.swift
//  intergalacticplanetary
//
//  Created by Kenny Schlagel on 2/3/16.
//  Copyright © 2016 Kenny Schlagel. All rights reserved.
//

import Foundation

struct APODRouter {
  var urlComponents = NSURLComponents()
  let apiKey = "DEMO_KEY" // replace with your API key
  
  init() {
    urlComponents.scheme = "https"
    urlComponents.host = "api.nasa.gov"
    urlComponents.path = "/planetary/apod"
  }
  
  func createURLWithComponentsForDate(date: NSDate) -> NSURL? {
    let dateQuery = NSURLQueryItem(name: "date", value: dateToString(date))
    let apiKeyQuery = NSURLQueryItem(name: "api_key", value: apiKey)
    let hdQuery = NSURLQueryItem(name: "hd", value: "true")
    
    urlComponents.queryItems = [dateQuery, apiKeyQuery, hdQuery]

    return urlComponents.URL
  }
  
  func dateToString(date: NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.stringFromDate(date)
  }
}