//
//  FirstViewController.swift
//  intergalacticplanetary
//
//  Created by Kenny Schlagel on 2/3/16.
//  Copyright © 2016 Kenny Schlagel. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var apodNameLabel: UILabel!
  @IBOutlet weak var apodCopyLabel: UILabel!
  @IBOutlet weak var favoritesButton: UIButton!
  @IBOutlet weak var errorLabel: UILabel!
  @IBOutlet weak var favoritesErrorLabel: UILabel!
  @IBOutlet weak var apodExpLabel: UITextView!
  @IBOutlet weak var yesterdayButton: UIButton!
  @IBOutlet weak var todayButton: UIButton!
  @IBOutlet weak var spinner: UIActivityIndicatorView!

  var APODDate = NSDate()
  
  let isFavoriteButtonColorYes: UIColor = UIColor(red: 1, green: 208/255, blue: 87/255, alpha: 0.9)
  let isFavoriteButtonColorNo: UIColor = UIColor.whiteColor()
  let maxFavoritesCount = 2
  
  var weAreComingFromASegue = false
  
  var apodOnView: APOD?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if !weAreComingFromASegue {
      getAPODForViewUsingDate(NSDate())
    }
  }
  
  override func viewWillAppear(animated: Bool) {
    checkIfFavorite()
  }
  
  func getAPODForViewUsingDate(date: NSDate) {
    if !weAreComingFromASegue { spinner.startAnimating() }
    
    APOD.getAPODForDate(date: date) { [weak self] (apods, error) in
      guard error == nil, let apod = apods else {
        if let error = error as? APODServiceError {
          self?.errorLabel.text = error.rawValue
        } else if let error = error as? NSError {
          self?.errorLabel.text = error.localizedDescription
        } else {
          self?.errorLabel.text = "Houston, we had a probelm doing that..."
        }
        // load a backup image
        self?.useBackupAPOD()
        UIView.animateWithDuration(1.5) {
          self?.animateView()
        }
        return
      }
      
      guard let photoURL = apod.photoUrl else {
        // load a backup image
        self?.useBackupAPOD()
        UIView.animateWithDuration(1.5) {
          self?.animateView()
        }
        return
      }
      NASAClient.sharedInstance.getImageDataFromUrl(photoURL) { [weak self] (image, error) in
        if let image = image {
          // this is the only time we should set the apodOnView
          self?.apodOnView = apod
          self?.setUpView(image, apod: apod)
          
          UIView.animateWithDuration(1.5) {
            self?.animateView()
          }
          self?.checkIfFavorite()
        } else {
          self?.setGenericErrorMessage()
        }
      }
    }
  }
  
  private func getYesterdaysDateFrom(date: NSDate) -> NSDate {
    return date.dateByAddingTimeInterval(-1*24*60*60)
  }
  
  private func checkDatesMatch(from: NSDate, to: NSDate) -> Bool {
    let compare = NSCalendar.currentCalendar().compareDate(from, toDate: to, toUnitGranularity: .Day)
    if compare == .OrderedSame {
      return true
    }
      return false
  }
  
  @IBAction func todayPressed(sender: AnyObject) {
    var localToday = NSDate()
    if checkDatesMatch(localToday, to: APODDate) {
      return
    }
    UIView.animateWithDuration(0.5) {
      self.clearView()
    }
    getAPODForViewUsingDate(localToday)
    self.APODDate = localToday
  }
  
  @IBAction func yesterdayPressed(sender: AnyObject) {
    let newDate = getYesterdaysDateFrom(APODDate)
    UIView.animateWithDuration(1.5) {
      self.clearView()
    }
    getAPODForViewUsingDate(newDate)
    self.APODDate = newDate
  }
  
  
  //MARK: Favorites
  @IBAction func favoritePressed(sender: AnyObject) {
    if let apod = apodOnView {
      let isFavorite = FavoritesManager.sharedInstance.favorites.filter { $0.itemId == apod.itemId }.first
      if let isFavorite = isFavorite {
        // remove
        FavoritesManager.sharedInstance.toggleFavorite(isFavorite)
      } else {
        //check if maxed out
        if FavoritesManager.sharedInstance.favorites.count > self.maxFavoritesCount {
          self.favoritesErrorLabel.text = "You can only have \(self.maxFavoritesCount) favorites"
          return
        }
        // add
        FavoritesManager.sharedInstance.toggleFavorite(apod)
      }
      checkIfFavorite()
    }
  }
  
  private func checkIfFavorite() {
    let isFavorite = FavoritesManager.sharedInstance.favorites.filter { $0.itemId == apodOnView?.itemId }.first
    if isFavorite != nil {
      self.favoritesButton.tintColor = isFavoriteButtonColorYes
    } else {
      self.favoritesButton.tintColor = isFavoriteButtonColorNo
    }
  }
  
  // MARK: Backup
  private func useBackupAPOD() {
    let backup = APOD.getBackup()
    let apod = APOD(backup: backup)
    self.setUpView(backup.image, apod: apod, withFavButton: false)
  }
  
  // MARK:  View Setup and Animation Methods
  private func setUpView(image: UIImage?, apod: APOD, withFavButton: Bool = true) {
    // texts and image
    self.imageView.image = image
    self.apodNameLabel.text = apod.title
    self.apodExpLabel.text = apod.explanation
    let copy = apod.copyright ?? "NASA"
    self.apodCopyLabel.text = "© " + copy
    
    //alphas
    self.imageView.alpha = 0
    self.apodNameLabel.alpha = 0
    self.apodExpLabel.alpha = 0
    self.apodCopyLabel.alpha = 0
    self.favoritesButton.alpha = 0
    self.yesterdayButton.alpha = 0
    self.todayButton.alpha = 0
    
    // x and y animations
    self.apodNameLabel.frame.origin.x += 100
    self.apodExpLabel.frame.origin.x -= 200
    self.apodCopyLabel.frame.origin.y += 200
    self.favoritesButton.frame.origin.y += 500
    self.yesterdayButton.frame.origin.y -= 500
    self.todayButton.frame.origin.x -= 600
    
    // favorites button
    self.favoritesButton.hidden = false
    if withFavButton {
      self.favoritesButton.alpha = 0.9
    } else {
      self.favoritesButton.hidden = true
    }
    
    // with error?
    self.errorLabel.text = apod.error
    
    // misc ui setups
    self.apodExpLabel.textContainerInset = UIEdgeInsetsZero
  }
  
  private func animateView() {
    
    // alphas
    self.imageView.alpha = 1
    self.apodNameLabel.alpha = 1
    self.apodExpLabel.alpha = 1
    self.apodCopyLabel.alpha = 1
    self.yesterdayButton.alpha = 1
    self.todayButton.alpha = 1
    
    // x + y animations
    self.apodExpLabel.frame.origin.x += 200
    self.apodNameLabel.frame.origin.x -= 100
    self.apodCopyLabel.frame.origin.y -= 200
    self.favoritesButton.frame.origin.y -= 500
    self.yesterdayButton.frame.origin.y += 500
    self.todayButton.frame.origin.x += 600
    
    if !weAreComingFromASegue { spinner.stopAnimating() }
  }
  
  private func clearView() {
    self.imageView.image = nil
    self.apodNameLabel.text = nil
    self.apodExpLabel.text = nil
    self.apodCopyLabel.text = nil
  }
  
  private func setGenericErrorMessage() {
    self.errorLabel.text = "Houston, we had a problem loading the image.  Please relaunch."
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}