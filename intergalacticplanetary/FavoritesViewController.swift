//
//  FavoritesViewController.swift
//  intergalacticplanetary
//
//  Created by Kenny Schlagel on 2/10/16.
//  Copyright © 2016 Kenny Schlagel. All rights reserved.
//

import UIKit

class FavoritesViewController: UICollectionViewController {
  
  private let cellIdentifier = "stellarPhotoCell"
  private let detailSegueID = "showAPOD"
  
  lazy var dateFormatter = NSDateFormatter()
  
  override func viewWillAppear(animated: Bool) {
    collectionView?.reloadData()
  }
  
  // MARK: CollectionView Delegate Stuff
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return FavoritesManager.sharedInstance.favorites.count
  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! APODCell
    cell.apod = FavoritesManager.sharedInstance.favorites[indexPath.row]
    return cell
  }
  
  override func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier(detailSegueID, sender: nil)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if let tabbarVC = segue.destinationViewController as? UITabBarController, destinationVC = tabbarVC.viewControllers?[0] as? FirstViewController, selectedIndex = collectionView?.indexPathsForSelectedItems()?.first {
      let selectedAPOD = FavoritesManager.sharedInstance.favorites[selectedIndex.row]
      dateFormatter.dateFormat = "yyyy-MM-dd"
      
      guard let date = selectedAPOD.date  else {
        return
      }
      guard let d = dateFormatter.dateFromString(date) else {
        return
      }
      
      // we have an apod an a date, lets set the VC correctly
      destinationVC.weAreComingFromASegue = true
      destinationVC.getAPODForViewUsingDate(d)
      destinationVC.apodOnView = selectedAPOD
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
