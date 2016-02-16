//
//  FavoritesManager.swift
//  intergalacticplanetary
//
//  Created by Kenny Schlagel on 2/3/16.
//  Copyright © 2016 Kenny Schlagel. All rights reserved.
//
import Foundation

class FavoritesManager {
  var favorites: [APOD]
  static let favoritesKey = "Favorites"
  static let sharedInstance = FavoritesManager()
  
  init() {
    if let data = NSUserDefaults.standardUserDefaults().objectForKey(FavoritesManager.favoritesKey) as? NSData,
      favoritesArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [APOD] {
        favorites = favoritesArray
    } else {
      favorites = [APOD]()
    }
  }
  
  func toggleFavorite(apod: APOD) {
    let isFavorite = FavoritesManager.sharedInstance.favorites.filter { $0.itemId == apod.itemId }.first
    if let isFavorite = isFavorite {
      removeFavorite(apod)
    } else {
      addFavorite(apod)
    }
  }
  
  // MARK: helper methods
  
  private func addFavorite(apod: APOD) {
    favorites.append(apod)
    saveFavorites()
  }
  
  private func removeFavorite(apod: APOD) {
    if let index = favorites.indexOf(apod) {
      favorites.removeAtIndex(index)
      saveFavorites()
    }
  }
  
  private func saveFavorites() {
    let data = NSKeyedArchiver.archivedDataWithRootObject(favorites)
    NSUserDefaults.standardUserDefaults().setObject(data, forKey: FavoritesManager.favoritesKey)
  }
}