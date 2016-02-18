//
//  NASAClient.swift
//  intergalacticplanetary
//
//  Created by Kenny Schlagel on 2/3/16.
//  Copyright © 2016 Kenny Schlagel. All rights reserved.
//

import UIKit

typealias NetworkResult = (AnyObject?, ErrorType?) -> Void
typealias ImageResult = (UIImage?, ErrorType?) -> Void

class NASAClient {
  static let sharedInstance = NASAClient()
  private var urlSession: NSURLSession
  
  init() {
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    let queue = NSOperationQueue()
    queue.qualityOfService = .UserInitiated
    urlSession = NSURLSession(configuration: configuration, delegate: nil, delegateQueue: queue)
  }
  
  func getDataFromUrl(url: NSURL, completion: NetworkResult) {
    let request = NSURLRequest(URL: url)
    let task = urlSession.dataTaskWithRequest(request) {
      [unowned self] (data, reponse, error) in
      
      guard let data = data else {
        dispatch_async(dispatch_get_main_queue(), {
          completion(nil, NetworkClientError.MetaData)
        })
        return
      }
      self.parseJSON(data, completion: completion)
    }
    task.resume()
  }
  
  func getImageDataFromUrl(url: NSURL, completion: ImageResult) -> NSURLSessionDownloadTask {
    let request = NSURLRequest(URL: url)
    let task = urlSession.downloadTaskWithRequest(request) {
      [unowned self] (fileURL, response, error) in
      guard let fileURL = fileURL else {
        dispatch_async(dispatch_get_main_queue(), {
          completion(nil, NetworkClientError.ImageFileUrl)
        })
        return
      }
      if let data = NSData(contentsOfURL: fileURL), image = UIImage(data: data), response = response {
        let cachedResponse = NSCachedURLResponse(response: response, data: data)
        self.urlSession.configuration.URLCache?.storeCachedResponse(cachedResponse, forRequest: request)
        dispatch_async(dispatch_get_main_queue(), {
          completion(image, nil)
        })
      } else {
        dispatch_async(dispatch_get_main_queue(), {
          completion(nil, NetworkClientError.ImageData)
        })
      }
    }
    task.resume()
    return task
  }
  
  private func parseJSON(data: NSData, completion: NetworkResult) {
    do {
      let parseResults = try NSJSONSerialization.JSONObjectWithData(data, options: [])
      if let dictionary = parseResults as? NSDictionary {
        dispatch_async(dispatch_get_main_queue(), {
          completion(dictionary, nil)
        })
      } else if let array = parseResults as? [NSDictionary] {
        dispatch_async(dispatch_get_main_queue(), {
          completion(array, nil)
        })
      }
    } catch {
      dispatch_async(dispatch_get_main_queue(), {
        completion(nil, NetworkClientError.JSONParse)
      })
    }
  }
  
  // TODO: plan for escaped quotes
  private func fixedJSONData(data: NSData) -> NSData {
    guard let jsonString = String(data: data, encoding: NSUTF8StringEncoding) else { return data }
    let fixedString = jsonString.stringByReplacingOccurrencesOfString("\\", withString: "'")
    if let fixedData = fixedString.dataUsingEncoding(NSUTF8StringEncoding) {
      return fixedData
    } else {
      return data
    }
  }
}

//MARK:  Network Client Error Enum

enum NetworkClientError: ErrorType {
  case ImageData
  case JSONParse
  case MetaData
  case ImageFileUrl
}