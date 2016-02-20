//
//  APODCell.swift
//  intergalacticplanetary
//
//  Created by Kenny Schlagel on 2/10/16.
//  Copyright © 2016 Kenny Schlagel. All rights reserved.
//

import UIKit

class APODCell: UICollectionViewCell {
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var photoImageLabel: UILabel!
  @IBOutlet weak var photoImageCopy: UILabel!
  
  var imageTask: NSURLSessionDownloadTask?
  
  var apod: APOD? {
    didSet {
      imageTask?.cancel()
      guard let photoUrl = apod?.photoUrl else {
//        self.photoImageLabel.text = "Downloading..."
//        self.photoImageLabel.textColor = UIColor.grayColor()
//        self.photoImageCopy.text = ""
//        print("downloading")
        return
      }
      imageTask = NASAClient.sharedInstance.getImageDataFromUrl(photoUrl) { [weak self] (image, error) in
        guard error == nil else {
          self?.photoImageView.image = nil
          self?.photoImageLabel.text = "Loading..."
          self?.photoImageCopy.text = ""
          return
        }

        self?.photoImageView.image = image
        self?.photoImageLabel.text = self?.apod?.title
        self?.photoImageLabel.textColor = UIColor.whiteColor()
        let copy = self?.apod?.copyright ?? "NASA"
        self?.photoImageCopy.text = "© " + copy
      }
    }
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    apod = nil
  }
}
