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

class LoginViewController: UIViewController, NSURLConnectionDelegate {
    
    @IBOutlet weak var _username: UITextField?
    @IBOutlet weak var _password: UITextField?
    @IBOutlet weak var rememberCredentials: UISwitch!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var loadLabel: UILabel!
    
    //@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    var keyChainUser: String?
    var keyChainPwd: String?
    var isUsrSaved:Bool = false
    var isPwdSaved:Bool = false
    var isUsrRemoved:Bool = true
    var isPwdRemoved:Bool = true
    var bConst: NSLayoutConstraint?
    var timerVal: Timer?
    var counter: Int = 0
    fileprivate var ping1: NSString?
    fileprivate var httpReq: Data?
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: window.origin.y + window.height - keyboardSize.height)
        } else {
            debugPrint("Window frame is nil.")
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
        } else {
            debugPrint("Window frame is nil.")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLabel.isHidden = true
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        //self.bConst = self.bottomConstraint
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
    
    func displayAlertMessage(title: String, message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    
    @IBAction func login(_ sender: Any) {
        var username = _username?.text
        var password = _password?.text
        if (username?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (password?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            
            displayAlertMessage(title: "Validation", message: "All fields are required")
            return
        }
        username = username?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        password = password?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (timerVal == nil) {
        timerVal = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleTimeOut), userInfo: nil, repeats: true)
        }
        self.verifyLogin(username: username!, password: password!)
        //self.rlabLogin(username: username!, password: password!)
    }
    
    func handleTimeOut() {
        if (self.counter >= 8) {
            self.timerVal?.invalidate()
            self.timerVal = nil
            self.viewDidLoad()
            self.view.isUserInteractionEnabled = true
            self.displayAlertMessage(title: "Time Out", message: "Connection timed out. Check your internet connection and retry")
            self.counter = 0
        }
        self.loadLabel.textColor = UIColor(red:   .random(),
                                           green: .random(),
                                           blue:  .random(),
                                           alpha: 1.0)
        self.counter = self.counter+1
        
    }
    
    func verifyLogin(username: String, password: String) {
        self.view.isUserInteractionEnabled = false
        self.loadLabel.isHidden = false
        
        let parameters: Parameters = ["j_username": username, "j_password": password]
        print("parameters:\n",parameters)

        Alamofire.request("https://itsapps.odu.edu/auth/", method: .get, headers: ["Accept":"text/html; application/vnd.paos+xml","PAOS":"ver='urn:liberty:paos:2003-08';'urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp'"])
            .responseData { response in
                print("Response 1\n",response)
                if let data = response.result.value {
                    self.httpReq = data
                    let dataString:NSData = data as NSData
                    let ping1 = NSString(data: dataString as Data, encoding: String.Encoding.ascii.rawValue)!
                    print("Data 1\n",ping1)
                    if (response.response?.statusCode == 200) {
                        let plainString = "\(username):\(password)"
                        let plainData = plainString.data(using: .utf8)
                        let base64String =  plainData?.base64EncodedString()
                        print("64 ENCODING", base64String!)
                        Alamofire.request("https://shibboleth.odu.edu/idp/profile/SAML2/SOAP/ECP", method: .post, parameters: ["firstPing":data], encoding: "httpBody", headers: ["Authorization":"Basic \(base64String!)","Content-Type":"text/xml"])
                            .responseData { response in
                                if let dataNew = response.result.value {
                                    print("Response 2\n",response)
                                    let dataString:NSData = dataNew as NSData
                                    let str = NSString(data: dataString as Data, encoding: String.Encoding.ascii.rawValue)!
                                    print("Data 2\n",str)
                                    print("*************")
                                    print("response code \(response.response?.statusCode)")
                                    //Success
                                    if (dataNew != nil && response.response?.statusCode == 200) {
                                        self.rlabLogin(username: username, password: password)
                                    }
                                    else if (dataNew != nil && response.response?.statusCode == 401){
                                        self.timerVal?.invalidate()
                                        self.timerVal = nil
                                        self.loadLabel.isHidden = true
                                        self.displayAlertMessage(title: "Authencation Failed", message: "The  MIDAS ID and password you entered don't match")
                                        self.view.isUserInteractionEnabled = true
                                    }else{
                                        print("failed 2nd call to SOAP")
                                        self.timerVal?.invalidate()
                                        self.timerVal = nil
                                        self.displayAlertMessage(title: "Authencation Failed", message: "Failed to log in. Contact admin.")
                                        self.loadLabel.isHidden = true
                                        self.view.isUserInteractionEnabled = true
                                    }
                                }
                        }
                    }
                    else{
                        print("failed 1st call to itsapps.odu.edu/auth/")
                        self.timerVal?.invalidate()
                        self.timerVal = nil
                        self.displayAlertMessage(title: "Authencation Failed", message: "ODU Servers are not currently available")
                        self.loadLabel.isHidden = true
                        self.view.isUserInteractionEnabled = true
                    }
                } else {
                    self.timerVal?.invalidate()
                    self.timerVal = nil
                    self.displayAlertMessage(title: "Authencation Failed", message: "Could not connect to the server")
                    self.loadLabel.isHidden = true
                    self.view.isUserInteractionEnabled = true
                }
        }
    }
    
    
    func rlabLogin(username: String, password: String) {
        
        let parameters: Parameters = ["username":username, "deviceid": Manager.deviceId == nil ? "abc" : Manager.deviceId!, "devicetype" : "iOS"]
        Alamofire.request(Manager.loginService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseData { response in
                
                self.timerVal?.invalidate()
                self.timerVal = nil
                self.counter = 0
                print("Request:\(response.request)")  // original URL request
                print("Response:\(response.response)") // HTTP URL response
                print("Rsponse data:\(response.data)")
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    
                    print("Data: \(utf8Text)")
                    print("After data")
                    if let dict = self.convertToDictionary(text: utf8Text) {
                        if (dict["user_details"] != nil) {
                            Manager.userData = dict["user_details"] as! [String: Any]
                            Manager.beaconDetails = dict["beacon_details"] as! [[String: Any]]
                            print("beacon details: \(Manager.beaconDetails)")
                            
                            if let user = Manager.userData?["midas_id"] as? String {
                                print("user from dict:\(String(describing: user))")
                                
                                if user == username {
                                    self.loadLabel.isHidden = true
                                    if (self.rememberCredentials.isOn == true) {
                                        self.isUsrSaved = KeychainWrapper.standard.set(user, forKey: "username")
                                        
                                        let retrievedUsername: String? = KeychainWrapper.standard.string(forKey: "username")
                                        if (retrievedUsername != nil) {
                                            self.keyChainUser = retrievedUsername!
                                        }
                                        self.isPwdSaved = KeychainWrapper.standard.set(password, forKey: "password")
                                        let retrievedPwd: String? = KeychainWrapper.standard.string(forKey: "password")
                                        if(retrievedPwd != nil) {
                                            self.keyChainPwd = retrievedPwd!
                                        }
                                        
                                    }
                                    else if(self.rememberCredentials.isOn == false) {
                                        self.isUsrRemoved = KeychainWrapper.standard.removeObject(forKey: "username")
                                        self.isPwdRemoved = KeychainWrapper.standard.removeObject(forKey: "password")
                                    }
                                    
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let destinationController = storyboard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController

                                    UIApplication.shared.keyWindow?.rootViewController = destinationController
                                    let tabBarController = destinationController.frontViewController as! CustomTabBarController
                                    if (Manager.userData?["role"] as! String == "student") {
                                        let tabBarControllerItems = tabBarController.tabBar.items
                                        if let tabItemsArray = tabBarControllerItems {
                                            tabItemsArray[1].isEnabled = false
                                            tabItemsArray[2].isEnabled = false
                                        }
                                    }
                                    Manager.triggerNotifications = true
                                    self.present(destinationController, animated: true, completion: nil)
                                }
                                else {
                                    self.view.isUserInteractionEnabled = true
                                    self.loadLabel.isHidden = true
                                    self.displayAlertMessage(title: "Validation", message: "Username mismatch")
                                    self._username?.text = nil
                                    self._password?.text = nil
                                    print("Username mismatch")
                                }
                            }
                        } else {
                            let str = dict["responseKey"] as! String
                            if (str.range(of: "Exception") != nil) {
                                self.displayAlertMessage(title: "Authencation Failed", message: str)
                            } else {
                                self.displayAlertMessage(title: "Authencation Failed", message: "User info missing")
                            }
                            self.view.isUserInteractionEnabled = true
                            self.loadLabel.isHidden = true
                            self._username?.text = nil
                            self._password?.text = nil
                        }
                    }
                    else {
                        self.view.isUserInteractionEnabled = true
                        self.loadLabel.isHidden = true
                        self.displayAlertMessage(title: "Authencation Failed", message: "invalid response format")
                        self._username?.text = nil
                        self._password?.text = nil
                    }
                    
                }
                else {
                    self.view.isUserInteractionEnabled = true
                    self.loadLabel.isHidden = true
                    self.displayAlertMessage(title: "Authencation Failed", message: "No response from server")
                    self._username?.text = nil
                    self._password?.text = nil
                }
        }
        
    }
    
}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest() //try URLEncoding().encode(urlRequest, with: parameters)
        print(parameters)
        let temp = parameters!["firstPing"] as? Data
        let str = NSString(data: temp!, encoding: String.Encoding.ascii.rawValue)!
        request.httpBody = str.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
        print(request.httpBody)
        return request
    }
    
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}









