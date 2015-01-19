//
//  ViewController.swift
//  CodeGram
//
//  Created by Jon Vogel on 1/12/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//

import UIKit
import Social

class MainViewController: UIViewController, ImageTransferProtocol, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {

  //MARK: Properties
  //Create and instantiate the alert controller that will display our action sheet
  let alertController = UIAlertController(title: "Options", message: "What do you want to do with this photo?", preferredStyle: UIAlertControllerStyle.Alert)
  var imageView = UIImageView(frame: UIScreen.mainScreen().bounds)
  var arrayOfFilteredImages: [UIImage] = [UIImage]()
  var filterCollectionView: UICollectionView?
  var filterNames: [String] = [String]()
  var arrayOfThumbnails = [ThumbNail]()
  var graphiContext: CIContext!
  let imageQueue = NSOperationQueue()
  var thumbNailImage: UIImage?
  var doneButton: UIBarButtonItem!
  var btnShare: UIBarButtonItem!
  var btnUndo: UIBarButtonItem!
  
  //MARK: App lifecycle
  override func loadView() {
    //make the root view
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    //make and set up the UIImage view that will overlay the mainview
    imageView.backgroundColor = UIColor.grayColor()
    //set up the image view
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(imageView)
    //make and set up the button
    let optionsButton = UIButton()
    optionsButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(optionsButton)
    optionsButton.setTitle("Options", forState: UIControlState.Normal)
    optionsButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
    optionsButton.addTarget(self, action: "optionsButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
    //Set up the Colleciton View that will hold the filter
    let filterCollectionViewLayout = UICollectionViewFlowLayout()
    filterCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: filterCollectionViewLayout)
    filterCollectionViewLayout.itemSize = CGSize(width: 50, height: 50)
    filterCollectionViewLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    rootView.addSubview(filterCollectionView!)
    filterCollectionView!.setTranslatesAutoresizingMaskIntoConstraints(false)
    
//    self.alertController.popoverPresentationController?.sourceRect = rootView.bounds
//    self.alertController.popoverPresentationController?.sourceView = rootView

    
    
    
    //create the dictionary of views that will be used to look up views to assign constraints
    let views = ["optionsButton": optionsButton, "imageView": self.imageView, "filterCollectionView": filterCollectionView!]//, "bar": bar]
    //Call the setUpConstraints method and pass it the rootView and the Dictionary of other views
    self.setUpConstraints(rootView, otherViews: views)
    //Set up the collecitonview delegate and data source
    self.filterCollectionView?.dataSource = self
    self.filterCollectionView?.delegate = self
    self.filterCollectionView?.registerClass(ItemCellViewController.self, forCellWithReuseIdentifier: "FilterCell")
    //Finally set the view property of the ViewController to the rootview
    
    self.view = rootView
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //Set Up some stuff to prepare for photo editing
    let options = [kCIContextWorkingColorSpace: NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.graphiContext = CIContext(EAGLContext: eaglContext, options: options)
    self.setUpThumbNails()
    let image1 = UIImage(named: "image1.JPG")
    //self.imageView.image = image1!
    //self.thumbNailImage = image1!
    self.transferImage(image1!)
    
    //Set up Bar button items
    self.doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Bordered, target: self, action: "done")
    self.btnShare = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareSelected")
    self.btnUndo = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Undo, target: self, action: "undoButtonPressed")
    self.navigationItem.rightBarButtonItem = btnShare
    //Add gallery action
    let galleryAction = UIAlertAction(title: "Go to Gallery", style: UIAlertActionStyle.Default) { (theAction) -> Void in
      //code to fire when action pressed
      let DVC = GalleryViewController()
      DVC.delegate = self
      self.navigationController?.pushViewController(DVC, animated: true)
    }
    //assign the gallery action to the UIActionController
    self.alertController.addAction(galleryAction)
    
    //Add the filter action
    let filterAction = UIAlertAction(title: "Apply Filter", style: UIAlertActionStyle.Default) { (action) -> Void in
      //Add code to animate the filter collection view into the frame
      let constraintsOnView = self.view.constraints() as [NSLayoutConstraint]
      for n in constraintsOnView{
        if n.identifier != nil {
          switch n.identifier!{
          case "filterVerticalConstraint":
            n.constant = 10
          case "imageViewBottomConstraint":
            n.constant = 100
          case "imageViewTopConstraint":
            n.constant = 75
          case "imageViewLeftConstraint":
            n.constant = 25
          case "imageViewRightConstraint":
            n.constant = 25
          default:
            break
          }
        }
      }
      UIView.animateWithDuration(0.9, animations: { () -> Void in
        self.view.layoutIfNeeded()
      })
      self.navigationItem.rightBarButtonItem = self.doneButton
      self.navigationItem.leftBarButtonItem = self.btnUndo
    }
    self.alertController.addAction(filterAction)
    

    
    
    
    //Create and assign the camera action to the pop up menu if a camera exists
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
        
      }
      self.alertController.addAction(cameraAction)
    }
    
    //Create and Assign the action that allows the user to select photos from their phone
    let getPhotoOption = UIAlertAction(title: "Get Your Photos", style: UIAlertActionStyle.Default) { (action) -> Void in
      let DVC = UserPhotosViewController()
      DVC.delegate = self
      DVC.appMainImageSize = self.imageView.frame.size
      self.navigationController?.pushViewController(DVC, animated: true)
    }
    
    self.alertController.addAction(getPhotoOption)
    
    
  }
  
  
  //MARK: Other Functions
  //function that handles the options button being pressed
  func optionsButtonPressed(){
    //show the alertViewController when the user presses the options button
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
//  func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
//    popoverPresentationController.sourceView = self.view
//    popoverPresentationController.sourceRect = self.view.bounds
//    //popoverPresentationController.pres = UIModalPresentationStyle.OverFullScreen
//    
//  }
  
  //Function that is called by the delegator
  func transferImage(image: UIImage) {
    self.imageView.image = image
    self.generateThumbnail(image)
    for TN in arrayOfThumbnails {
      TN.originalImage = self.thumbNailImage
      TN.filteredImage = nil
    }
    self.filterCollectionView!.reloadData()
  }
  
  //function to set up the arrayOfThumbNails that our collection view controller will use
  func setUpThumbNails(){
    self.filterNames = ["CIColorInvert", "CIPhotoEffectInstant", "CIPhotoEffectTonal", "CIGloom", "CIPhotoEffectChrome", "CIPhotoEffectNoir", "CIPhotoEffectMono"]//, "CICrystallize"]
    for TN in self.filterNames {
      let oneTN = ThumbNail(name: TN, queue: self.imageQueue, context: self.graphiContext)
      arrayOfThumbnails.append(oneTN)
    }
    
  }
  
  //function to change the original picture to a smaller version that will be displayed on the thumbnails
  func generateThumbnail(originalImage: UIImage) {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.thumbNailImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
  
  func done() {
    let constraintsOnView = self.view.constraints() as [NSLayoutConstraint]
    
    for n in constraintsOnView{
      if n.identifier != nil {
        switch n.identifier!{
        case "filterVerticalConstraint":
          n.constant = -75
        case "imageViewBottomConstraint":
          n.constant = 10
        case "imageViewTopConstraint":
          n.constant = 65
        case "imageViewLeftConstraint":
          n.constant = 0
        case "imageViewRightConstraint":
          n.constant = 0
        default:
          break
        }
      }
    }
    UIView.animateWithDuration(0.9, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    self.navigationItem.rightBarButtonItem = btnShare
    self.navigationItem.leftBarButtonItem = nil
  }
  
  func undoButtonPressed() {
    if arrayOfFilteredImages.isEmpty != true {
      self.imageView.image = self.arrayOfFilteredImages.removeLast()
      //self.arrayOfFilteredImages.removeLast()
    }
  }
  
  func shareSelected() {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
      let shareViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
      shareViewController.addImage(self.imageView.image)
      presentViewController(shareViewController, animated: true, completion: nil)
    }else{
      println("Not Signed into Facebook")
    }
  }
  
  //MARK: Image Picker controller methods
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    //let i = info[UIImagePickerControllerEditedImage] as? UIImage
    self.transferImage(info[UIImagePickerControllerEditedImage] as UIImage!)
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  //MARK: collection view controller methods
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return arrayOfThumbnails.count
  }
  
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let Cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCell", forIndexPath: indexPath) as ItemCellViewController
    let theTN = arrayOfThumbnails[indexPath.row]
    if self.thumbNailImage != nil{
      if theTN.filteredImage == nil {
        theTN.generateFilteredImage()
        Cell.imageView.image = theTN.filteredImage
      }
    }
    return Cell
  }
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    self.arrayOfFilteredImages.append(self.imageView.image!)
    let startImage = CIImage(image: self.imageView.image)
    let filter = CIFilter(name: self.filterNames[indexPath.row])
    filter.setDefaults()
    filter.setValue(startImage, forKey: kCIInputImageKey)
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = result.extent()
    let imageRef = self.graphiContext.createCGImage(result, fromRect: extent)
    self.imageView.image = UIImage(CGImage: imageRef)
    
  }
  
  
  
  //MARK: Constraints set up
  func setUpConstraints( mainView: UIView, otherViews: [String:AnyObject]){
    //Array to hold constraints
    var arrayOfConstrainst = [NSLayoutConstraint]()
    //Constraints for the Options Button
    let optionsButtonConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[optionsButton]-20-|", options: nil , metrics: nil, views: otherViews)
    let optionsButtonConstraintHorizontal = NSLayoutConstraint(item: otherViews["optionsButton"] as UIView!, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: mainView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
    //Add Button constraints to array of constraints
    for c in optionsButtonConstraintVertical as [NSLayoutConstraint]{
      arrayOfConstrainst.append(c)
    }
    arrayOfConstrainst.append(optionsButtonConstraintHorizontal)
    //Add constrainst to the UIImageView
    let imageViewVerticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-65-[imageView]-10-|", options: nil, metrics: nil, views: otherViews) as [NSLayoutConstraint]
    imageViewVerticalConstraints[0].identifier = "imageViewTopConstraint"
    imageViewVerticalConstraints[1].identifier = "imageViewBottomConstraint"
    let imageViewHorizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-|", options: nil, metrics: nil, views: otherViews) as [NSLayoutConstraint]
    imageViewHorizontalConstraints[0].identifier = "imageViewLeftConstraint"
    imageViewHorizontalConstraints[1].identifier = "imageViewRightConstraint"
    //Add image View constraints to the Image View
    for c in imageViewVerticalConstraints as [NSLayoutConstraint]{
      arrayOfConstrainst.append(c)
    }
    for c in imageViewHorizontalConstraints as [NSLayoutConstraint]{
      arrayOfConstrainst.append(c)
    }
    
    //Set up Constraints for the filter collection view
    let filterViewHeightConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[filterCollectionView(75)]", options: nil, metrics: nil, views: otherViews) as [NSLayoutConstraint]
    self.filterCollectionView?.addConstraints(filterViewHeightConstraint)
    let filterViewVerticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:[filterCollectionView]-(-75)-|", options: nil, metrics: nil, views: otherViews) as [NSLayoutConstraint]
    filterViewVerticalConstraint[0].identifier = "filterVerticalConstraint"
    let filterViewHorizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[filterCollectionView]|", options: nil, metrics: nil, views: otherViews)
    for c in filterViewVerticalConstraint as [NSLayoutConstraint]{
      arrayOfConstrainst.append(c)
    }
    for c in filterViewHorizontalConstraint as [NSLayoutConstraint]{
      arrayOfConstrainst.append(c)
    }
    //add constraints to main view
    mainView.addConstraints(arrayOfConstrainst)
  }
  

}

