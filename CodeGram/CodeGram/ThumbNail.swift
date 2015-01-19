//
//  ThumbNail.swift
//  CodeGram
//
//  Created by Jon Vogel on 1/13/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import Foundation
import UIKit

class ThumbNail {
  
  var originalImage: UIImage?
  var filteredImage: UIImage?
  var filterName: String
  var imageQueue: NSOperationQueue
  var graphicContext: CIContext
  
  init(name: String, queue: NSOperationQueue, context: CIContext){
    self.filterName = name
    self.imageQueue = queue
    self.graphicContext = context
    
    
    
    
  }
  
  func generateFilteredImage() {
    let startImage = CIImage(image: self.originalImage)
    if self.filterName != "CICrystallize"{
      let filter = CIFilter(name: self.filterName)
      filter.setDefaults()
      filter.setValue(startImage, forKey: kCIInputImageKey)
      let result = filter.valueForKey(kCIOutputImageKey) as CIImage
      let extent = result.extent()
      let imageRef = self.graphicContext.createCGImage(result, fromRect: extent)
      self.filteredImage = UIImage(CGImage: imageRef)
    }else{
      //let paramOne = NSNumber(float: 19.50)
      //let paramTwo = CIVector(x: 150, y: 150)
      //let dicOfParams = ["Radius": paramOne, "Center": paramTwo]
      let filter = CIFilter(name: filterName, withInputParameters: nil)
      filter.setDefaults()
      filter.setDefaults()
      filter.setValue(startImage, forKey: kCIInputImageKey)
      let result = filter.valueForKey(kCIOutputImageKey) as CIImage
      let extent = result.extent()
      let imageRef = self.graphicContext.createCGImage(result, fromRect: extent)
      self.filteredImage = UIImage(CGImage: imageRef)
    }
    
    //let filter = CIFilter(name: self.filterName)
    
    
  }
  
  
  
  
}