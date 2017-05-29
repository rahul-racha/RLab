//
//  ViewController.swift
//  RLab
//
//  Created by rahul rachamalla on 1/24/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftKeychainWrapper

class ViewController: UIViewController, NSURLConnectionDelegate {

    //@IBOutlet weak var _username: UIView!
    @IBOutlet weak var _username: UITextField?
    @IBOutlet weak var _password: UITextField?
    @IBOutlet weak var rememberCredentials: UISwitch!
    var keyChainUser: String?
    var keyChainPwd: String?
    var isUsrSaved:Bool = false
    var isPwdSaved:Bool = false
    var isUsrRemoved:Bool = true
    var isPwdRemoved:Bool = true
//    var switchState = Bool()
//    var userName = String()
//    var password = String()
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        Manager.triggerNotifications = false
        keyChainUser = KeychainWrapper.standard.string(forKey: "username")
        if(keyChainUser != nil) {
        _username?.text = keyChainUser!
        }
        keyChainPwd = KeychainWrapper.standard.string(forKey: "password")
        if(keyChainPwd != nil) {
        _password?.text = keyChainPwd!
        }
        rememberCredentials.addTarget(self, action: #selector(setWhenStateChanged(_:)), for: UIControlEvents.valueChanged)
//        switchState = UserDefaults.standard.bool(forKey: "switchState")
//        userName = UserDefaults.standard.string(forKey: "keepUsername")!
//        password = UserDefaults.standard.string(forKey: "keepPassword")!
        // Do any additional setup after loading the view, typically from a nib.
        
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.     
    }

    func setWhenStateChanged(_ sender:UISwitch!) {
        if(sender.isOn == false) {
            self.isUsrRemoved = KeychainWrapper.standard.removeObject(forKey: "username")
            self.isPwdRemoved = KeychainWrapper.standard.removeObject(forKey: "password")
        }

    }
    
        
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    
    @IBAction func login(_ sender: UIButton) {
        let username = _username?.text
        let password = _password?.text
        var user: String?
        //var userData: [String: Any]?
        
        if (username?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (password?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            
            displayAlertMessage(message: "All fields are required")
            return
        }
        
            
            let parameters: Parameters = ["username":username! , "password": password!, "deviceid": Manager.deviceId == nil ? "abc" : Manager.deviceId!]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/login.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/
            .responseJSON { response in
                
                debugPrint("All Response Info: \(response)")
                
                print("Request:\(response.request)")  // original URL request
                print("Response:\(response.response)") // HTTP URL response
                print("Rsponse data:\(response.data)")
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    
                    print("Data: \(utf8Text)")	
                    print("After data")
                    if let dict = self.convertToDictionary(text: utf8Text) {
                        print(dict as Any)
                        let userFromData = (dict["username"] as! String)
                        if !userFromData.isEmpty {
                            print(userFromData as Any)
                            user = userFromData
                        }
                        
                        
                        print("user from dict:\(user)")
                        
                        if user != nil,user! == username! {
                            
                            if(/*self.keyChainUser != nil && */self.rememberCredentials.isOn == true) {
                            self.isUsrSaved = KeychainWrapper.standard.set(user!, forKey: "username")
                            
                            let retrievedUsername: String? = KeychainWrapper.standard.string(forKey: "username")
                                if (retrievedUsername != nil) {
                                    self.keyChainUser = retrievedUsername!
                                }
                            self.isPwdSaved = KeychainWrapper.standard.set(password!, forKey: "password")
                                let retrievedPwd: String? = KeychainWrapper.standard.string(forKey: "password")
                                if(retrievedPwd != nil) {
                                    self.keyChainPwd = retrievedPwd!
                                }

                            } 
                            else if(self.rememberCredentials.isOn == false) {
                                self.isUsrRemoved = KeychainWrapper.standard.removeObject(forKey: "username")
                                self.isPwdRemoved = KeychainWrapper.standard.removeObject(forKey: "password")
                            }
//                            var enteredUser = username!
//                            var enteredPassword = password!
//                            var user = PFUser.currentUser()
//                            UserDefaults.standard.set(enteredUser, forKey: "keepUsername")
//                            UserDefaults.standard.set(enteredPassword, forKey: "keepPassword")
//                            UserDefaults.standard.synchronize()
//                            
//                            self.actInd.startAnimating()
//                            PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, NSError) -> Void in
//                            self.actInd.stopAnimating(
                            
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let destinationController = storyboard.instantiateViewController(withIdentifier: "tabBarController")
                            //let sv = storyboard.instantiateViewController(withIdentifier: "successView") as! LocationViewController
                            //let sv.userData = dict
                            Manager.userData = dict
                            if (Manager.userData!["status"] as! String == "Yes") {
                                Manager.userPresent = true
                            } else {
                                Manager.userPresent = false
                            }
                            Manager.triggerNotifications = true
                            self.present(destinationController, animated: true, completion: nil)
//                            )
//                            }
                        }
                        else {
                            self.displayAlertMessage(message: "Invalid username or password")
                            self._username?.text = nil
                            self._password?.text = nil
                            print("invalid username & password")
                        }
                    }
                    else {
                        self.displayAlertMessage(message: "invalid account details")
                        self._username?.text = nil
                        self._password?.text = nil
                    }
                    
                }
                else {
                    self.displayAlertMessage(message: "response data is empty")
                    self._username?.text = nil
                    self._password?.text = nil
                }
        }
    }
    
    
}









