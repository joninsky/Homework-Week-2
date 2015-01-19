//
//  ThumbNailModel.swift
//  PhotoFellows
//
//  Created by Jon Vogel on 1/16/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import UIKit

class ThumbNailModel {
  
  var originalImage: UIImage?
  var filteredImage: UIImage?
  var filterName: String?
  var context: CIContext?
  
  
  init(filterName: String, context: CIContext){
    self.filterName = filterName
    self.context = context
  }
  
  func geterateFIlteredImage() {
    let startImage = CIImage(image: self.originalImage)
    let filter = CIFilter(name: self.filterName)
    filter.setDefaults()
    filter.setValue(startImage, forKey: kCIInputImageKey)
    let results = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = results.extent()
    let imageReference = self.context?.createCGImage(results, fromRect: extent)
    self.filteredImage = UIImage(CGImage: imageReference)
    
  }
  
  
}
