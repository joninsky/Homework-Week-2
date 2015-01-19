//
//  UserPhotosViewController.swift
//  CodeGram
//
//  Created by Jon Vogel on 1/14/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import Foundation
import UIKit
import Photos

class UserPhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  
  //MARK: Properties
  //collectionViewController
  var userCollectionViewController: UICollectionView!
  //properties for photos
  var appMainImageSize: CGSize!
  var arrayOfFetchedResults: PHFetchResult!
  var imageManager: PHCachingImageManager!
  //declare Delegate Property
  var delegate: ImageTransferProtocol!
  var userCollectionLayout: UICollectionViewFlowLayout!
  
  //MARK: View LifeCycle
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    self.userCollectionViewController = UICollectionView(frame: rootView.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    self.userCollectionLayout = userCollectionViewController.collectionViewLayout as UICollectionViewFlowLayout
    self.userCollectionLayout.itemSize = CGSize(width: 100, height: 100)
    self.userCollectionLayout.sectionInset = UIEdgeInsetsMake(10, 50, 10, 50)
    self.userCollectionViewController.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(userCollectionViewController)
    self.view = rootView
    
  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "pinched:")
    self.userCollectionViewController.addGestureRecognizer(pinchRecognizer)
    self.imageManager = PHCachingImageManager()
    self.arrayOfFetchedResults = PHAsset.fetchAssetsWithOptions(nil)
    self.userCollectionViewController.dataSource = self
    self.userCollectionViewController.delegate = self
    self.userCollectionViewController.registerClass(ItemCellViewController.self, forCellWithReuseIdentifier: "userCollectionCell")
    
    
  }
  
  
  //MARK: Collection View Methods
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let Cell = collectionView.dequeueReusableCellWithReuseIdentifier("userCollectionCell", forIndexPath: indexPath) as ItemCellViewController
    let asset = arrayOfFetchedResults[indexPath.row] as PHAsset
    self.imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 100, height: 100), contentMode: PHImageContentMode.AspectFill, options: nil ) { (requestedImage, infoDictionary) -> Void in
      Cell.imageView.image = requestedImage
    }
    return Cell
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return arrayOfFetchedResults.count
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let asset = arrayOfFetchedResults[indexPath.row] as PHAsset
    self.imageManager.requestImageForAsset(asset, targetSize: self.appMainImageSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (returnedImage, dictionaryOfInfo) -> Void in
      self.delegate.transferImage(returnedImage)
    }
    self.navigationController!.popViewControllerAnimated(true)
  }
  
  //MARK: Gesture recognizer
  func pinched (sender: UIPinchGestureRecognizer ) {
    
    switch sender.state{
    case UIGestureRecognizerState.Ended:
      self.userCollectionViewController.performBatchUpdates({ () -> Void in
        if sender.velocity > 0{
          let newSize = CGSize(width: self.userCollectionLayout.itemSize.width * 2, height: self.userCollectionLayout.itemSize.height * 2)
          self.userCollectionLayout.itemSize = newSize
        }else if sender.velocity < 0{
          let newSize = CGSize(width: self.userCollectionLayout.itemSize.width / 2, height: self.userCollectionLayout.itemSize.height / 2)
          self.userCollectionLayout.itemSize = newSize
        }
      }, completion: { (tf) -> Void in
      })
    default:
      break
    }
    
    
  }
  
  
}