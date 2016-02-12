//
//  displayUserInfo.swift
//  login
//
//  Created by Gagandeep Singh on 2/9/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class displayUserInfo: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var usersName: UILabel!
    
    @IBOutlet weak var userSummary: UITextField!
    
    @IBOutlet weak var userAge: UITextField!
    
    var base64String : String?
    
    var serverRoot = Firebase(url: "https://login1234.firebaseIO.com/")
    
    var userRef : Firebase?
    
    var decodedData: NSData?
    
    var decodedImage: UIImage?
    
    var age: String?
    
    var userText: String?
    
    
    
    func loadImage(){
        if(serverRoot.authData.uid == nil){
            var token = NSUserDefaults.standardUserDefaults().stringForKey("token")
            serverRoot.authWithCustomToken(token, withCompletionBlock: { (error, auth) -> Void in
            })
        }
        userRef!.observeEventType(.Value, withBlock: { snapshot in
            self.base64String = snapshot.value.objectForKey("Picture") as? String
            if(self.decodedData != nil){
                self.decodedData = NSData(base64EncodedString: self.base64String!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                self.decodedImage = UIImage(data: self.decodedData!)
                self.profilePicture.image = self.decodedImage
            }
        })
    }
    
    @IBAction func updateInfoButtonTapped(sender: AnyObject) {
        let userInfo = ["userInfo": self.userSummary.text!]
        userRef!.updateChildValues(userInfo)
    }
    
    func loadData(){
        loadImage()
        userRef!.observeEventType(.Value, withBlock: { snapshot in
            self.userAge.text = "Age: " + (snapshot.value.objectForKey("Age")! as! String)
        })
        
        userRef!.observeEventType(.Value, withBlock: { snapshot in
            self.usersName.text = (snapshot.value.objectForKey("Full_Name") as? String)! + "'s Profile"
            
        })
        userRef!.observeEventType(.Value, withBlock: { snapshot in
            if(snapshot.hasChild("userInfo") && snapshot.valueForKeyPath("userInfo") != nil ){
                self.userSummary.text = snapshot.valueForKeyPath("userInfo") as? String
            }
        })
    }
    

    override func viewDidLoad(){
        super.viewDidLoad()
        userRef = serverRoot.childByAppendingPath("users").childByAppendingPath(serverRoot.authData.uid)
        loadData()
        
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}