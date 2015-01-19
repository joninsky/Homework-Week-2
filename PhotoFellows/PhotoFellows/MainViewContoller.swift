//
//  ViewController.swift
//  PhotoFellows
//
//  Created by Jon Vogel on 1/16/15.
//  Copyright (c) 2015 Jon Vogel. All rights reserved.
//
import Foundation
import UIKit
import Social

class MainViewContoller: UIViewController, ImageTransferProtocol, UICollectionViewDataSource , UICollectionViewDelegate{

  //let OS = NSLocalizedString("Options", comment: "Aler Title")
  var alerController = UIAlertController( title: NSLocalizedString("Options", comment: "Aler Title"), message: NSLocalizedString("What do you want to do?", comment: "Aler Comment"), preferredStyle: UIAlertControllerStyle.ActionSheet)
  var myImageView: UIImageView?
  var btnOptionsButton: UIButton?
  var btnDoneButton: UIBarButtonItem?
  var btnUndo: UIBarButtonItem?
  var btnShare: UIBarButtonItem?
  var filterCollectionView: UICollectionView?
  var filterCollectionViewFlowLayout: UICollectionViewFlowLayout?
  var tapTapRecognizer: UITapGestureRecognizer?
  var filterNames: [String]?
  var graphiContext: CIContext!
  var arrayOfThumbNails = [ThumbNailModel]()
  var imageForThumbnailSize: UIImage?
  var arrayOfFilteredImages: [UIImage]?
  //var
  
  override func loadView() {
    //Set Up the Root View
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    //set Up the Image View 
    self.myImageView = UIImageView()//frame: UIScreen.mainScreen().bounds)
    self.myImageView?.backgroundColor = UIColor.greenColor()
    self.myImageView?.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(self.myImageView!)
    // Set up Buttons
    self.btnOptionsButton = UIButton()
    self.btnOptionsButton?.setTitle(NSLocalizedString("  Get Photo  ",  comment: "Get photo button text"), forState: UIControlState.Normal)
    self.btnOptionsButton?.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.btnOptionsButton?.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    self.btnOptionsButton?.addTarget(self, action: "mainButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
    self.btnOptionsButton?.backgroundColor = UIColor.whiteColor()
    self.btnOptionsButton?.layer.cornerRadius = 10
    rootView.addSubview(self.btnOptionsButton!)
    //set up the COllection view, this includes the flow layout
    self.filterCollectionViewFlowLayout = UICollectionViewFlowLayout()
    self.filterCollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.filterCollectionViewFlowLayout!)
    self.filterCollectionViewFlowLayout?.itemSize = CGSize(width: 50, height: 50)
    self.filterCollectionViewFlowLayout?.scrollDirection  = UICollectionViewScrollDirection.Horizontal
    self.filterCollectionView?.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(self.filterCollectionView!)
    //Set up the Done Button 
    self.btnDoneButton = UIBarButtonItem(title: NSLocalizedString("Done", comment: "NavController Done Button"), style: UIBarButtonItemStyle.Bordered, target: self, action: "doneButtonSelected")
    self.btnUndo = UIBarButtonItem(title: NSLocalizedString("Undo", comment: "NavController Undo Button"), style: UIBarButtonItemStyle.Bordered, target: self, action: "undoButtonSelected")
    self.btnShare = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonSelected")
    //Create Dictionary and call the method that adds the constraints
    let dictionaryOfViews = ["optionsButton": self.btnOptionsButton!, "imageView": self.myImageView!, "filterCollectionView": self.filterCollectionView!]
    setUpConstraints( rootView, otherViews: dictionaryOfViews)
    self.view = rootView
    
  }
  
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.filterCollectionView?.dataSource = self
    self.filterCollectionView?.delegate = self
    self.filterCollectionView?.registerClass(PickerPhotoCell.self, forCellWithReuseIdentifier: "FilterCell")
    // Do any additional setup after loading the view, typically from a nib.
    self.tapTapRecognizer = UITapGestureRecognizer(target: self, action: "doubleTapTap:")
    self.tapTapRecognizer?.numberOfTapsRequired = 2
    self.view.addGestureRecognizer(tapTapRecognizer!)
    //Set Up some stuff to prepare for photo editing
    let options = [kCIContextWorkingColorSpace: NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.graphiContext = CIContext(EAGLContext: eaglContext, options: options)
    self.setUpThumbNails()
  }
  
  
  //MARK: Button actions
  func mainButtonPressed(){
    let DVC = PickerViewController()
    DVC.delegate = self
    DVC.mainImageSize = self.myImageView?.frame.size
    self.navigationController?.pushViewController(DVC, animated: true)
  }
  
  func doneButtonSelected(){
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
      self.navigationItem.rightBarButtonItem = self.btnShare
      self.navigationItem.leftBarButtonItem = nil
    
  }
  
  func undoButtonSelected(){
    if arrayOfFilteredImages?.isEmpty != true {
      self.myImageView?.image = self.arrayOfFilteredImages?.removeLast()
      //self.arrayOfFilteredImages.removeLast()
    }
    
  }
  func shareButtonSelected(){
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
      let shareViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
      shareViewController.addImage(self.myImageView?.image)
      presentViewController(shareViewController, animated: true, completion: nil)
    }else{
      println("Not Signed into Facebook")
    }
  }
  
  func doubleTapTap(sender: UITapGestureRecognizer ) {
    
    if sender.state == UIGestureRecognizerState.Ended{
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
      self.navigationItem.rightBarButtonItem = self.btnDoneButton
      self.navigationItem.leftBarButtonItem = self.btnUndo
    }
    
    
  }
  
  //MARK: Filter and thumbnail Functions
  
  func setUpThumbNails(){
    self.filterNames = ["CIColorInvert", "CIPhotoEffectInstant", "CIPhotoEffectTonal", "CIGloom", "CIPhotoEffectChrome", "CIPhotoEffectNoir", "CIPhotoEffectMono"]
    for TN in self.filterNames! {
      let oneTN = ThumbNailModel(filterName: TN, context: self.graphiContext)
      arrayOfThumbNails.append(oneTN)
    }
    
  }
  
  func generateThumbnail(originalImage: UIImage) {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.imageForThumbnailSize = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
  
  
  
  //MARK: protocol function
  func transferImage (theImage: UIImage){
    self.myImageView?.image = theImage
    self.navigationItem.rightBarButtonItem = btnShare
    //self.btnOptionsButton?.setTitle(NSLocalizedString("  Options  ", comment: "Main Button state after image has been selected"), forState: UIControlState.Normal)
    self.generateThumbnail(theImage)
    for TN in arrayOfThumbNails{
      TN.originalImage = self.imageForThumbnailSize
      TN.filteredImage = nil
    }
    self.filterCollectionView?.reloadData()
    
  }
  
  //MARK: Collection View Shit
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return arrayOfThumbNails.count
    
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let Cell = collectionView.dequeueReusableCellWithReuseIdentifier("FilterCell", forIndexPath: indexPath) as PickerPhotoCell
    let TN = arrayOfThumbNails[indexPath.row]
    if self.imageForThumbnailSize != nil {
      if TN.filteredImage == nil {
        TN.geterateFIlteredImage()
        Cell.imageView.image = TN.filteredImage
      }
    }
    
    
    return Cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    self.arrayOfFilteredImages?.append(self.myImageView!.image!)
    let startImage = CIImage(image: self.myImageView!.image!)
    let filter = CIFilter(name: self.filterNames![indexPath.row])
    filter.setDefaults()
    filter.setValue(startImage, forKey: kCIInputImageKey)
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = result.extent()
    let imageRef = self.graphiContext.createCGImage(result, fromRect: extent)
    self.myImageView?.image = UIImage(CGImage: imageRef)
    
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

