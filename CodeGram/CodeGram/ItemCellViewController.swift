//
//  ItemViewController.swift
//  CodeGram
//
//  Created by Jon Vogel on 1/12/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import Foundation
import UIKit

class ItemCellViewController: UICollectionViewCell {
  
  let imageView = UIImageView()
  
  
  override init(frame: CGRect){
    super.init(frame: frame)
    self.addSubview(self.imageView)
    self.backgroundColor = UIColor.whiteColor()
    imageView.frame = self.bounds
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.layer.masksToBounds = true
    var dictionaryOfViews = ["imageView": imageView]
    let imageViewVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: nil, metrics: nil, views: dictionaryOfViews)
    let imageViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: nil, metrics: nil, views: dictionaryOfViews)
    self.addConstraints(imageViewVerticalConstraint)
    self.addConstraints(imageViewHorizontalConstraints)
   // self.addTheConstraints(self.contentView, viewCollection: dictionaryOfViews)
  }
  
  required init (coder aCoder: NSCoder){
    super.init(coder: aCoder)
  }
  
  
}