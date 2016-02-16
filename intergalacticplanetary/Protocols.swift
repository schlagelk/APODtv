//
//  Protocols.swift
//  intergalacticplanetary
//
//  Created by Kenny Schlagel on 2/9/16.
//  Copyright © 2016 Kenny Schlagel. All rights reserved.
//

import Foundation
import UIKit

protocol APODBackup: APODDataSource {
  var image: UIImage { get }
  var error: String { get }

}

protocol APODDataSource {
  var itemId: String? { get }
  var photoUrl: NSURL? { get }
  var title: String? { get }
  var explanation: String? { get }
  var copyright: String? { get }
  var date: String? { get }
}