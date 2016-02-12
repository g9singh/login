//
//  AfterLogin.swift
//  
//
//  Created by Gagandeep Singh on 1/31/16.
//
//

import Foundation
import UIKit
import Firebase

class AfterLogin: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate{
    //****************** buttons and texts fields ******************//
    //logout button
    @IBOutlet weak var lougoutBT: UIButton!
    //first name text field
    @IBOutlet weak var nameTF: UITextField!
    //date picker
    @IBOutlet weak var datePicker: UIDatePicker!
    //submit button
    @IBOutlet weak var submitBT: UIButton!
    
    @IBOutlet weak var genderPickerView: UIPickerView!
    
    
    //****************** alerts to users ******************//
    //message to say wrong password
    let nameAlert = UIAlertController(title: "Missing First or Last name", message: "You must enter something for both first and last name. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
    //message to say that user info was sucessfully uploaded to the server
    let userInfoAlert = UIAlertController(title: "Info Sucessfully Updated", message: "Your information was saved. Please click OK to move on.", preferredStyle: UIAlertControllerStyle.Alert)
    
    //****************** grabs user authentication from previous page ******************//
    var serverRoot = Firebase(url: "https://login1234.firebaseIO.com/")
    var userRef: Firebase?
    
    
    //****************** other global variables ******************//
    var pickerDataSource = ["Female", "Male", "Other"];
    var gender = ""
    
    
    //****************** updates user's info ******************//
    @IBAction func submitButtonTap(sender: AnyObject) {
        if(nameTF.text == nil){
            self.presentViewController(self.nameAlert, animated: true, completion: nil)
        }
        else{
            //get date from wheel
            let date = datePicker.date
            //get calendar
            let calendar : NSCalendar = NSCalendar.currentCalendar()
            //calculate age in years
            let ageComponents = calendar.components(NSCalendarUnit.Year, fromDate: date, toDate: NSDate(), options: [])
            let age = ageComponents.year
            //add info into right format
            let userInfo = ["Full_Name": nameTF.text!, "Age": String(age), "Gender": gender, "Points" : "10"]
            //push to server and update user info
            userRef?.updateChildValues(userInfo, withCompletionBlock: { (error, firbase) in
                
            })
        }
    }
    
    //****************** unauthenticates user and goes back to login screen ******************//
    @IBAction func logOutTap(sender: AnyObject) {
        serverRoot.unauth()
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "token")
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let newVC :UIViewController = storyboard.instantiateViewControllerWithIdentifier("loginVC") as UIViewController
        self.presentViewController(newVC, animated: true, completion: nil)
    }
    
    //****************** these methods handle the view picker ******************//
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch (row){
        case 0:
            gender = "Female"
            break
        case 1:
            gender = "Male"
            break
        case 2:
            gender = "Other"
            break
        default:
            gender = "Other"
            break
        }
    }
    
    //****************** set up app before starting ******************//
    override func viewDidLoad() {
        //setting up the view picker
        genderPickerView.delegate = self;
        genderPickerView.dataSource = self;
        
        //setting up the user refrence to the server with UID
        userRef = serverRoot.childByAppendingPath("users").childByAppendingPath(serverRoot.authData.uid)
        
        //setting up the name text field
        nameTF.delegate = self
        nameTF.autocapitalizationType = .Words
        
        //setting up the alert to tell user that the name is invalid
        nameAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.nameAlert.resignFirstResponder()
        }))
        
        //setting up the alert to tell user that information was sucessfully pushed to the server
        userInfoAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.userInfoAlert.resignFirstResponder()
        }))
        
        //setting up the keboard to dismiss whenever something outside the TF is touched
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    //****************** when text fields get finished with editing******************//
    @IBAction func touchOutsideTF(sender: AnyObject) {
        didEndOnExit()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view!.endEditing(true)
        return true
    }
    func didEndOnExit(){
        self.view!.endEditing(true)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}















