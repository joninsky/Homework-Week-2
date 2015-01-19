//
//  UserViewController.swift
//  PhotoFellows
//
//  Created by Jon Vogel on 1/16/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import Foundation
import UIKit
import Photos

class PickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  var photoCollectionView: UICollectionView?
  var photoCollectionVIewFlowLayout: UICollectionViewFlowLayout?
  var arrayOfFetchedResults: PHFetchResult?
  var imageManager: PHCachingImageManager?
  var btnCamera : UIBarButtonItem?
  var delegate: ImageTransferProtocol?
  var pinchRecognizer : UIPinchGestureRecognizer?
  var mainImageSize: CGSize?
  
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    self.photoCollectionVIewFlowLayout = UICollectionViewFlowLayout()
    self.photoCollectionView = UICollectionView(frame: rootView.bounds, collectionViewLayout: photoCollectionVIewFlowLayout!)
    self.photoCollectionVIewFlowLayout?.itemSize = CGSize(width: 100, height: 100)
     self.photoCollectionVIewFlowLayout?.sectionInset = UIEdgeInsetsMake(10, 50, 10, 50)
    self.photoCollectionView?.dataSource = self
    self.photoCollectionView?.delegate  = self
    self.photoCollectionView?.registerClass(PickerPhotoCell.self, forCellWithReuseIdentifier: "photoCell")
    rootView.addSubview(photoCollectionView!)
    //let dictionaryOfViews = ["collectionView": photoCollectionView]
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "pinched:")
    self.photoCollectionView?.addGestureRecognizer(pinchRecognizer!)
    self.imageManager = PHCachingImageManager()
    self.arrayOfFetchedResults = PHAsset.fetchAssetsWithOptions(nil)
    
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
    self.btnCamera = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "cameraButtonPressed")
    self.navigationItem.rightBarButtonItem = btnCamera
    }
    
  }
  
  
  
  func cameraButtonPressed() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    
  }
  
  //MARK: Image Picker controller methods
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    //let i = info[UIImagePickerControllerEditedImage] as? UIImage
    for item in info {
      println(item)
    }
    delegate?.transferImage(info[UIImagePickerControllerEditedImage] as UIImage!)
    self.navigationController?.popViewControllerAnimated(true)
    picker.dismissViewControllerAnimated(true, completion: nil)
    
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return arrayOfFetchedResults!.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let Cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as PickerPhotoCell
    let asset = arrayOfFetchedResults![indexPath.row] as PHAsset
    self.imageManager?.requestImageForAsset(asset, targetSize: CGSize(width: 100, height: 100), contentMode: PHImageContentMode.AspectFill, options: nil ) { (requestedImage, infoDictionary) -> Void in
      Cell.imageView.image = requestedImage
    }
    return Cell
  }
  
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let asset = arrayOfFetchedResults![indexPath.row] as PHAsset
    self.imageManager!.requestImageForAsset(asset, targetSize: self.mainImageSize!, contentMode: PHImageContentMode.AspectFill, options: nil) { (returnedImage, dictionaryOfInfo) -> Void in
      self.delegate!.transferImage(returnedImage)
    }
    self.navigationController!.popViewControllerAnimated(true)
  }
  
  func pinched(sender: UIPinchGestureRecognizer ) {
    
    switch sender.state{
    case UIGestureRecognizerState.Ended:
      self.photoCollectionView?.performBatchUpdates({ () -> Void in
        if sender.velocity > 0{
          let newSize = CGSize(width: self.photoCollectionVIewFlowLayout!.itemSize.width * 2, height: self.photoCollectionVIewFlowLayout!.itemSize.height * 2)
          self.photoCollectionVIewFlowLayout!.itemSize = newSize
        }else if sender.velocity < 0{
          let newSize = CGSize(width: self.photoCollectionVIewFlowLayout!.itemSize.width / 2, height: self.photoCollectionVIewFlowLayout!.itemSize.height / 2)
          self.photoCollectionVIewFlowLayout!.itemSize = newSize
        }
        }, completion: { (tf) -> Void in
          
          //Do nothing
      })
    default:
      break
    }
    
    
    
  }
  
  
  
  
  
}