//
//  imageController.swift
//  login
//
//  Created by Gagandeep Singh on 2/8/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import Firebase
import UIKit
class imageController: UIViewController, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    //submit button
    @IBOutlet weak var submitBT: UIButton!
    //image preview before upload
    @IBOutlet weak var imageView: UIImageView!
    //choose from gallary button
    @IBOutlet weak var chooseFromGallaryBT: UIButton!
    //take picture button
    @IBOutlet weak var takePictureBT: UIButton!
    //immage picker
    var picker:UIImagePickerController?=UIImagePickerController()
    //converted image into 64 base
    var base64String: NSString!
    //****************** grabs user authentication from previous page ******************//
    var serverRoot = Firebase(url: "https://login1234.firebaseIO.com/")
    var userRef: Firebase?
   
    
    
    //function that handles the app when the pick image button is tapped
    @IBAction func pickImageTap(sender: AnyObject) {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)){
            picker!.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.presentViewController(picker!, animated: true, completion: nil)
            submitBT.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            submitBT.enabled = true;
        }
    }
    
    //function that handles the app when the take picture button is tapped
    @IBAction func takePictureTap(sender: AnyObject) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)){
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker!, animated: true, completion: nil)
            submitBT.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            submitBT.enabled = true;
        }
    }
    
    //funtion that handles the app when the submit button is tapped
    @IBAction func submitTap(sender: AnyObject) {
        //make a new image holder
        var imageData: NSData = UIImageJPEGRepresentation(imageView.image!, 1)!
        var resolutionRatioReducer: CGFloat = 0.9
        
        //cuts down the size if its to big for firebase servers
        while(imageData.length > 10000000){
            imageData = UIImageJPEGRepresentation(imageView.image!, resolutionRatioReducer)!
            resolutionRatioReducer = resolutionRatioReducer - 0.1
        }
        base64String = imageData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
        let quoteString = ["Picture": base64String]
        userRef!.updateChildValues(quoteString)
    }
    
    @IBAction func skipBTTap(sender: AnyObject) {
        //userRef!.setNilValueForKey("Picture")
    }
    //******************* take care of image loading and camera taking picture *******************//
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController){
        submitBT.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        submitBT.enabled = false;
        dismissViewControllerAnimated(true, completion: nil)
    }
   
    override func viewDidLoad() {
        submitBT.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        submitBT.enabled = false;
        picker?.delegate = self
        userRef = serverRoot.childByAppendingPath("users").childByAppendingPath(serverRoot.authData.uid)
        super.viewDidLoad()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}