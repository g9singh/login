//trying to get the UItext editing to go to the next line when you hit next go or whaterver...
//  ViewController.swift
//  login
//
//  Created by Gagandeep Singh on 1/30/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITextFieldDelegate {
    
    //Mark:Properties
    
    //****************** create a refrence to Firebase server ******************//
    let serverRoot = Firebase(url: "https://login1234.firebaseIO.com/")
    
    //****************** Buttons ******************//
    //login password
    let passwordTF = UITextField()
    //login email
    let emailTF = UITextField()
    //sign up password
    let confirmPasswordTF = UITextField()
    //loginButton
    let loginButton = UIButton()
    //cancelButton
    let cancelButton = UIButton()
    //submit button for forgot password
    let submitBT = UIButton()
    //forgot password button
    let forgotPasswordBT = UIButton()
    //Sign up button
    let signUpButton = UIButton()
    //Login message at the top
    let loginLable = UILabel()
    //Dont have an account lable
    let noAccountLable = UILabel()
    
    
    //****************** alerts to users******************//
    //message to say wrong password
    let incorrectPassAlert = UIAlertController(title: "Incorrect Email or Password", message: "The email or password could not be verified. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
    //message to say incorrect email when resetting password
    let incorrectEmailAlert = UIAlertController(title: "Unrecognized Email", message: "The specified user account does not exist. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
    //message to say that password was reset sucessfully
     let passwordResetAlert = UIAlertController(title: "Password Reset Sucessful", message: "Please check your email for instructions on how to change your temporary password.", preferredStyle: UIAlertControllerStyle.Alert)
    //message to say that user account was sucessfully created
    let userCreatedAlert = UIAlertController(title: "User Created", message: "Your account was sucessfully created. You will now be logged in.", preferredStyle: UIAlertControllerStyle.Alert)
    //message to say that the email has already been used
    let userAlreadyExistsAlert = UIAlertController(title: "Email Already in Use", message: "The new user account cannot be created because the specified email address is already in use. Please enter a different email address.", preferredStyle: UIAlertControllerStyle.Alert)
    //message to let user know that entered passowrd did not match
    let confirmPassAlert = UIAlertController(title: "Passwords Do Not Match", message: "The entered passwords do not match. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
    //message to let user know that entered information was invalid
    let invalidInfoAlert = UIAlertController(title: "Email or Passowrd is invalid", message: "The entered email or passwords are invalid. Please try again.", preferredStyle: UIAlertControllerStyle.Alert)
    //message to let user know that entered information was invalid
    let somethingWrongAlert = UIAlertController(title: "Ooops", message: "Something on our end went wrong please report this problem to our developers. Thank you.", preferredStyle: UIAlertControllerStyle.Alert)
    
    
    
    //****************** button functions ******************//
    func signUpButton(sender: AnyObject) {
        if(confirmPasswordTF.hidden){
            confirmPasswordTF.hidden = false
            confirmPasswordTF.enabled = true
            
            loginButton.hidden = true
            loginButton.enabled = false
            
            cancelButton.hidden = false
            cancelButton.enabled = true
            
            forgotPasswordBT.hidden = true
            forgotPasswordBT.enabled = false
            
            passwordTF.hidden = false
            passwordTF.enabled = true
            
            submitBT.hidden = true
            submitBT.enabled = false
        }
        else if(emailTF.text != nil && passwordTF.text != nil && confirmPasswordTF.text != nil){
            if(passwordTF.text == confirmPasswordTF.text){
                createNewUser()
            }
            else{
                self.presentViewController(self.confirmPassAlert, animated: true, completion: nil)
            }
        }
        else{
            self.presentViewController(self.invalidInfoAlert, animated: true, completion: nil)
        }
    }
    //************ function for buttons ************//
    func tapLogin(sender: AnyObject) {
        if(emailTF.text == nil || passwordTF.text == nil){
            self.presentViewController(self.incorrectPassAlert, animated: true, completion: nil)
        }
        else{
            logIn()
        }
    }
    //************ function for buttons ************//
    func cancelButton(sender: AnyObject) {
        confirmPasswordTF.hidden = true
        confirmPasswordTF.enabled = false
        
        cancelButton.hidden = true
        cancelButton.enabled = false
        
        loginButton.hidden = false
        loginButton.enabled = true
        
        forgotPasswordBT.hidden = false
        forgotPasswordBT.enabled = true
        
        passwordTF.hidden = false
        passwordTF.enabled = true
        
        submitBT.hidden = true
        submitBT.enabled = false
    }
    //************ function for buttons ************//
    func forgotPassButton(sender: AnyObject) {
        submitBT.hidden = false
        submitBT.enabled = true
        
        passwordTF.hidden = true
        passwordTF.enabled = false
        
        loginButton.hidden = true
        loginButton.enabled = false
        
        cancelButton.hidden = false
        cancelButton.enabled = true
        
        forgotPasswordBT.hidden = true
        forgotPasswordBT.enabled = false
    }
    //************ function for buttons ************//
    func submitButton(sender: AnyObject) {
        if(emailTF.text != nil){
            forgotPassword()
        }
        else{
            self.presentViewController(self.confirmPassAlert, animated: true, completion: nil)
        }
    }
    //****************** when text fields get finished with editing******************//
    @IBAction func touchOutsideTF(sender: AnyObject) {
        self.didEndOnExit()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == emailTF){
            emailTF.resignFirstResponder()
            if(passwordTF.hidden != true){
                passwordTF.becomeFirstResponder()
            }
            else{
                submitBT.becomeFirstResponder()
                submitButton(self)
            }
            return true
        }
        else if(textField == passwordTF && confirmPasswordTF.hidden){
            passwordTF.resignFirstResponder()
            loginButton.becomeFirstResponder()
            logIn()
            return true
        }
        else if(textField == passwordTF && !confirmPasswordTF.hidden){
            passwordTF.resignFirstResponder()
            confirmPasswordTF.becomeFirstResponder()
            return true
        }
        else if(textField == confirmPasswordTF){
            confirmPasswordTF.resignFirstResponder()
            createNewUser()
            return true
        }
        self.view!.endEditing(true)
        return false
    }
    
    func didEndOnExit(){
        self.view!.endEditing(true)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    //****************** actual fucntions for backend processes ******************//
    
    //resets password given user's email address, prints error out otherwise
    func forgotPassword(){
        serverRoot.resetPasswordForUser(emailTF.text) { (error) -> Void in
            if(error != nil){
                self.presentViewController(self.incorrectEmailAlert, animated: true, completion: nil)
            }
            else{

                self.presentViewController(self.passwordResetAlert, animated: true, completion: nil)
            }
        }
    }
    
    //Function moves to screen after login
    func moveToLoginVC(){
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let newVC :UIViewController = storyboard.instantiateViewControllerWithIdentifier("displayUserInfo") as UIViewController
        self.presentViewController(newVC, animated: true, completion: nil)
    }
    
    //Authenticates the user
    func logIn(){
        serverRoot.authUser(emailTF.text, password: passwordTF.text,
            withCompletionBlock: { (error, auth) in
                if(error != nil){
                    // show the alert
                    self.presentViewController(self.incorrectPassAlert, animated: true, completion: nil)
                }
                else{
                    NSUserDefaults.standardUserDefaults().setValue(auth.token, forKey: "token")
                    self.moveToLoginVC()
                }
        })

    }
    
    //Function creates a new user
    func createNewUser(){
        if (passwordTF.text == confirmPasswordTF.text){
            serverRoot.createUser(emailTF.text, password: passwordTF.text,
                withValueCompletionBlock: { error, result in
                    if (error != nil) {
                        if(error.code == -9){
                            self.presentViewController(self.userAlreadyExistsAlert, animated: true, completion: nil)
                        }
                        if (error.code == -5){
                            self.presentViewController(self.invalidInfoAlert, animated: true, completion: nil)
                        }
                        else{
                            self.presentViewController(self.somethingWrongAlert, animated: true, completion: nil)
                        }
                    }
                    else {
                        self.presentViewController(self.userCreatedAlert, animated: true, completion: nil)
                        self.serverRoot.authUser(self.emailTF.text, password: self.passwordTF.text, withCompletionBlock: { (error, auth) -> Void in
                            let userRoot = self.serverRoot.childByAppendingPath("users")
                            let userID = auth.uid
                            let userInfo = ["Full_Name": "Unknown", "Age": "Unkown", "Gender": "Unknown", "Points" : "10"]
                            userRoot.childByAppendingPath(userID).setValue(userInfo)
                        })
                    }
            })
        }
        
    }
    func checkCurrentAuth(){
        let token = (NSUserDefaults.standardUserDefaults().stringForKey("token"))
        if(token != nil && serverRoot.authData.uid != nil){
            serverRoot.authWithCustomToken(token, withCompletionBlock: { (error, auth) -> Void in
                if(error != nil){
                    //make user log in manually
                }
                else{
                    //self.moveToLoginVC()
                }
            })
        }
    }
    
    func makeButtons(){
        var Xalignment = (self.view.frame.size.width - submitBT.frame.size.width)/2
        //Sumbit button
        submitBT.setTitle("Submit", forState: .Normal)
        submitBT.sizeToFit()
        submitBT.setTitleColor(UIColor.blueColor(), forState: .Normal)
        submitBT.frame = CGRectMake(Xalignment, 348, submitBT.frame.size.width, submitBT.frame.size.height)
        submitBT.addTarget(self, action: "submitButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(submitBT)
        
        //Login button
        loginButton.setTitle("Login", forState: .Normal)
        loginButton.sizeToFit()
        loginButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        Xalignment = (self.view.frame.size.width - loginButton.frame.size.width)/2
        loginButton.frame = CGRectMake(Xalignment, 267, loginButton.frame.size.width, loginButton.frame.size.height)
        loginButton.addTarget(self, action: "tapLogin:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(loginButton)
        
        //Forget button
        forgotPasswordBT.setTitle("Forgot Password", forState: .Normal)
        forgotPasswordBT.sizeToFit()
        forgotPasswordBT.setTitleColor(UIColor.redColor(), forState: .Normal)
        Xalignment = (self.view.frame.size.width - forgotPasswordBT.frame.size.width)/2
        forgotPasswordBT.frame = CGRectMake(Xalignment, 350, forgotPasswordBT.frame.size.width, cancelButton.frame.size.height)
        forgotPasswordBT.addTarget(self, action: "forgotPassButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(forgotPasswordBT)
        
        //Cancle button
        cancelButton.setTitle("Cancel", forState: .Normal)
        cancelButton.sizeToFit()
        cancelButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
        Xalignment = (self.view.frame.size.width - cancelButton.frame.size.width)/2
        cancelButton.frame = CGRectMake(Xalignment, 490, cancelButton.frame.size.width, cancelButton.frame.size.height)
        cancelButton.addTarget(self, action: "cancelButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton)
        
        //Signup Button
        signUpButton.setTitle("Sign Up", forState: .Normal)
        signUpButton.sizeToFit()
        signUpButton.setTitleColor(UIColor.yellowColor(), forState: .Normal)
        Xalignment = (self.view.frame.size.width - signUpButton.frame.size.width)/2
        signUpButton.frame = CGRectMake(Xalignment, 428, signUpButton.frame.size.width, signUpButton.frame.size.height)
        signUpButton.addTarget(self, action: "signUpButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(signUpButton)
    }
    
    func makeLables(){
        //log in lable
        var Xalignment = (self.view.frame.size.width - 100)/2
        loginLable.text = "Log in Please"
        loginLable.textAlignment = NSTextAlignment.Center
        loginLable.textColor = UIColor.blackColor()
        loginLable.font = UIFont.systemFontOfSize(17)
        loginLable.frame = CGRectMake(Xalignment, 20, 200, 20)
        self.view.addSubview(loginLable)
        
        //don't have account lable
        noAccountLable.text = "Don't have an Account?"
        noAccountLable.textAlignment = NSTextAlignment.Center
        noAccountLable.textColor = UIColor.blackColor()
        noAccountLable.font = UIFont.systemFontOfSize(17)
        Xalignment = (self.view.frame.size.width - 200)/2
        noAccountLable.frame = CGRectMake(Xalignment, 400, 200, 20)
        self.view.addSubview(noAccountLable)
    }
    
    func makeTextFields(){
        var Xalignment = (self.view.frame.size.width - 200)/2
        emailTF.placeholder = "Email address"
        emailTF.textAlignment = NSTextAlignment.Center
        emailTF.frame = CGRectMake(Xalignment, 173, 200, 30)
        emailTF.clearsOnBeginEditing = true;
        emailTF.clearButtonMode = UITextFieldViewMode.UnlessEditing;
        emailTF.secureTextEntry = false
        emailTF.backgroundColor = UIColor.whiteColor()
        emailTF.borderStyle = UITextBorderStyle.RoundedRect
        self.view.addSubview(emailTF)
        
        Xalignment = (self.view.frame.size.width - 200)/2
        passwordTF.placeholder = "Password"
        passwordTF.borderStyle = UITextBorderStyle.RoundedRect
        passwordTF.textAlignment = NSTextAlignment.Center
        passwordTF.frame = CGRectMake(Xalignment, 230, 200, 30)
        passwordTF.clearsOnBeginEditing = true;
        passwordTF.clearButtonMode = UITextFieldViewMode.UnlessEditing;
        passwordTF.secureTextEntry = true
        passwordTF.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(passwordTF)
        
        Xalignment = (self.view.frame.size.width - 200)/2
        confirmPasswordTF.placeholder = "Confrim Password"
        confirmPasswordTF.borderStyle = UITextBorderStyle.RoundedRect
        confirmPasswordTF.textAlignment = NSTextAlignment.Center
        confirmPasswordTF.frame = CGRectMake(Xalignment, 305, 200, 30)
        confirmPasswordTF.clearsOnBeginEditing = true;
        confirmPasswordTF.clearButtonMode = UITextFieldViewMode.UnlessEditing;
        confirmPasswordTF.secureTextEntry = true
        confirmPasswordTF.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(confirmPasswordTF)
    }
    //****************** set up app before starting ******************//
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCurrentAuth()
        makeButtons()
        makeLables()
        makeTextFields()
        
        submitBT.hidden = true
        submitBT.enabled = false
        
        confirmPasswordTF.hidden = true
        confirmPasswordTF.enabled = false
        
        cancelButton.hidden = true
        cancelButton.enabled = false
        
        self.emailTF.delegate = self
        self.passwordTF.delegate = self
        self.confirmPasswordTF.delegate = self
        
        // add an action (button)
        incorrectPassAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.incorrectPassAlert.resignFirstResponder()
        }))
        incorrectEmailAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.incorrectEmailAlert.resignFirstResponder()
        }))
        passwordResetAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.passwordResetAlert.resignFirstResponder()
        }))
        userCreatedAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.userCreatedAlert.resignFirstResponder()
            self.logIn()
        }))
        userAlreadyExistsAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.userAlreadyExistsAlert.resignFirstResponder()
        }))
        invalidInfoAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.userAlreadyExistsAlert.resignFirstResponder()
        }))
        confirmPassAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.userAlreadyExistsAlert.resignFirstResponder()
        }))
        somethingWrongAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            self.userAlreadyExistsAlert.resignFirstResponder()
        }))
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

