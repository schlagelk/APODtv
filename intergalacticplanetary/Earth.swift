//
//  Earth.swift
//  intergalacticplanetary
//
//  Created by Kenny Schlagel on 2/8/16.
//  Copyright © 2016 Kenny Schlagel. All rights reserved.
//

import Foundation
import UIKit

struct earth: APODDataSource, APODBackup {
  let itemId: String? = "http://apod.nasa.gov/apod/ap120130.html"
  let date: String?  = "2012-01-30"
  let photoUrl: NSURL? = NSURL(string: "http://apod.nasa.gov/apod/image/1201/bluemarbleearth_npp_8000.jpg")!
  let image = UIImage(named: "earth")!
  let title: String? = "Blue Marble Earth from Suomi NPP"
  let error: String = "Houston, we had a problem loading your APOD. So here is Earth."
  let copyright: String? = "NASA"
  let explanation: String? = "Behold one of the more detailed images of the Earth yet created. This Blue Marble Earth montage shown above -- created from photographs taken by the Visible/Infrared Imager Radiometer Suite (VIIRS) instrument on board the new Suomi NPP satellite -- shows many stunning details of our home planet. The Suomi NPP satellite was launched last October and renamed last week after Verner Suomi, commonly deemed the father of satellite meteorology. The composite was created from the data collected during four orbits of the robotic satellite taken earlier this month and digitally projected onto the globe. Many features of North America and the Western Hemisphere are particularly visible on a high resolution version of the image. Previously, several other Blue Marble Earth images have been created, some at even higher resolution."
}
