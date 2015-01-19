//
//  GalleryViewController.swift
//  CodeGram
//
//  Created by Jon Vogel on 1/12/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import Foundation
import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  
  //MARK: Properties
  var collectionView: UICollectionView!
  var arrayOfPictures = [UIImage]()
  var delegate: ImageTransferProtocol?
  var rootView: UIView!
  var dictionaryOfViews: [String: AnyObject]!
  
  //MARK: View life Cycle methods
  override func loadView() {
    rootView = UIView(frame: UIScreen.mainScreen().bounds)
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    collectionViewFlowLayout.itemSize = CGSize(width: 200, height: 200 )
    
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    collectionView.backgroundColor = UIColor.grayColor()
    rootView.addSubview(self.collectionView)
    //rootView.addSubview(navigationBar)
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    
    dictionaryOfViews = ["collectionView": collectionView]//, "navigationBar" : navigationBar]
    addConstraints(rootView, theOtherViews: dictionaryOfViews)
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView.registerClass(ItemCellViewController.self, forCellWithReuseIdentifier: "IMAGE_CELL")
    
    let image1 = UIImage(named: "image1.JPG")
    let image2 = UIImage(named: "image2.JPG")
    let image3 = UIImage(named: "image3.jpg")
    let image4 = UIImage(named: "image4.jpg")
    let image5 = UIImage(named: "image5.JPG")
    let image6 = UIImage(named: "image6.JPG")
    
    self.arrayOfPictures.append(image1!)
    self.arrayOfPictures.append(image2!)
    self.arrayOfPictures.append(image3!)
    self.arrayOfPictures.append(image4!)
    self.arrayOfPictures.append(image5!)
    self.arrayOfPictures.append(image6!)
    
  }
  
  
  //MARK: Collection View methods
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return arrayOfPictures.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let Cell = collectionView.dequeueReusableCellWithReuseIdentifier("IMAGE_CELL", forIndexPath: indexPath) as ItemCellViewController
    var theImage = self.arrayOfPictures[indexPath.row]
    Cell.imageView.image = theImage
    return Cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    delegate?.transferImage(arrayOfPictures[indexPath.row])
    self.navigationController?.popViewControllerAnimated(true)
  }

  
  
  
  //MARK: Constraints
  func addConstraints(mainView: UIView, theOtherViews: [String:AnyObject]) {
    var arrayOfConstraints = [NSLayoutConstraint]()
    let collectionViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-30-[collectionView]-30-|", options:nil, metrics: nil, views: theOtherViews)
    //let collectionViewVerticalConstraints = NSLayoutConstraint(item: theOtherViews["collectionView"] as UIView!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.topLayoutGuide, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0 )
    let collectionViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-30-[collectionView]-30-|", options:nil, metrics: nil, views: theOtherViews)
        for c in collectionViewVerticalConstraints as [NSLayoutConstraint]{
      arrayOfConstraints.append(c)
    }
    for c in collectionViewHorizontalConstraints as [NSLayoutConstraint]{
      arrayOfConstraints.append(c)
    }
    mainView.addConstraints(arrayOfConstraints)
  }
  
  
//End Class
}