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
    fileprivate var ping1: NSString?
    fileprivate var httpReq: Data?
    
    func keyboardWillShow(notification: NSNotification) {
       /* if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }*/
//        let info = notification.userInfo!
//        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        
//        UIView.animate(withDuration: 0.1, animations: { () -> Void in
//            self.bottomConstraint.constant = keyboardFrame.size.height + 20
//        })
        
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
        /*
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }*/
//        let info = notification.userInfo!
//        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        
//        UIView.animate(withDuration: 0.1, animations: { () -> Void in
//            if (self.bConst != nil) {
//            self.bottomConstraint.constant = (self.bConst?.constant)!
//            }
//        })
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
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    
    @IBAction func login(_ sender: Any) {
        var username = _username?.text
        var password = _password?.text
        var user: String?
        //var userData: [String: Any]?
        
        if (username?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (password?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            
            displayAlertMessage(message: "All fields are required")
            return
        }
        
        username = username?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        password = password?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        self.verifyLogin(username: username!, password: password!)
        //self.sLogin(username: "rahul", password: "123")
        
//            let parameters: Parameters = ["username":username! , "password": password!, "deviceid": Manager.deviceId == nil ? "abc" : Manager.deviceId!]
//        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/login.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/
//            .responseJSON { response in
//                
//                debugPrint("All Response Info: \(response)")
//                
//                print("Request:\(response.request)")  // original URL request
//                print("Response:\(response.response)") // HTTP URL response
//                print("Rsponse data:\(response.data)")
//                
//                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                    
//                    print("Data: \(utf8Text)")	
//                    print("After data")
//                    if let dict = self.convertToDictionary(text: utf8Text) {
//                        print(dict as Any)
//                        let userFromData = (dict["username"] as! String)
//                        if !userFromData.isEmpty {
//                            print(userFromData as Any)
//                            user = userFromData
//                        }
//                        
//                        
//                        print("user from dict:\(user)")
//                        
//                        if user != nil,user! == username! {
//                            
//                            if(/*self.keyChainUser != nil && */self.rememberCredentials.isOn == true) {
//                            self.isUsrSaved = KeychainWrapper.standard.set(user!, forKey: "username")
//                            
//                            let retrievedUsername: String? = KeychainWrapper.standard.string(forKey: "username")
//                                if (retrievedUsername != nil) {
//                                    self.keyChainUser = retrievedUsername!
//                                }
//                            self.isPwdSaved = KeychainWrapper.standard.set(password!, forKey: "password")
//                                let retrievedPwd: String? = KeychainWrapper.standard.string(forKey: "password")
//                                if(retrievedPwd != nil) {
//                                    self.keyChainPwd = retrievedPwd!
//                                }
//
//                            } 
//                            else if(self.rememberCredentials.isOn == false) {
//                                self.isUsrRemoved = KeychainWrapper.standard.removeObject(forKey: "username")
//                                self.isPwdRemoved = KeychainWrapper.standard.removeObject(forKey: "password")
//                            }
//                            
//                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                            let destinationController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! CustomTabBarController
//                            UIApplication.shared.keyWindow?.rootViewController = destinationController
//
//                            Manager.userData = dict
//                            if (Manager.userData!["status"] as! String == "Yes") {
//                                Manager.userPresent = true
//                            } else {
//                                Manager.userPresent = false
//                            }
//                            Manager.triggerNotifications = true
//                            Manager.controlLoadAllCells = false
//                            self.present(destinationController, animated: true, completion: nil)
//                        }
//                        else {
//                            self.displayAlertMessage(message: "Invalid username or password")
//                            self._username?.text = nil
//                            self._password?.text = nil
//                            print("invalid username & password")
//                        }
//                    }
//                    else {
//                        self.displayAlertMessage(message: "invalid account details")
//                        self._username?.text = nil
//                        self._password?.text = nil
//                    }
//                    
//                }
//                else {
//                    self.displayAlertMessage(message: "response data is empty")
//                    self._username?.text = nil
//                    self._password?.text = nil
//                }
//        }
 
    }
    
    func verifyLogin(username: String, password: String) {
    self.view.isUserInteractionEnabled = false
    self.loadLabel.isHidden = false
    self.btnLogin.isUserInteractionEnabled = false
    self.btnRegister.isUserInteractionEnabled = false
    //var parameters = Dictionary<String, String>()
    let parameters: Parameters = ["j_username": username, "j_password": password]
    //parameters["j_username"] = "\(username)"
    //parameters["j_password"] = "\(password)"
    print("parameters:\n",parameters)
    
        Alamofire.request("https://my.odu.edu", method: .get, headers: ["Accept":"text/html; application/vnd.paos+xml","PAOS":"ver='urn:liberty:paos:2003-08';'urn:oasis:names:tc:SAML:2.0:profiles:SSO:ecp'"])
        /*.validate()*/.responseData { response in
    //.response { (request, response, data, error) in
    print("Response 1\n",response)
            if let data = response.result.value {
            self.httpReq = data
    let dataString:NSData = data as NSData
    let ping1 = NSString(data: dataString as Data, encoding: String.Encoding.ascii.rawValue)!
    print("Data 1\n",ping1)
    
    //always error
    //print(error)
    
    if (response.response?.statusCode == 200) {
    
    let plainString = "\(username):\(password)"
    let plainData = plainString.data(using: .utf8)
    let base64String =  plainData?.base64EncodedString()
    //let base64String = plainData?.base64EncodedData(options: NSData.Base64EncodingOptions(rawValue: 0))
    
    print("64 ENCODING", base64String!)

        Alamofire.request("https://shibboleth.odu.edu/idp/profile/SAML2/SOAP/ECP", method: .post, parameters: ["firstPing":data], encoding: "httpBody"/*self.httpReq*//*CustomPostEncoding()*/, headers: ["Authorization":"Basic \(base64String!)","Content-Type":"text/xml"])
            .responseData { response in
            
                if let dataNew = response.result.value {
        
    print("Response 2\n",response)
    
    let dataString:NSData = dataNew as NSData
    let str = NSString(data: dataString as Data, encoding: String.Encoding.ascii.rawValue)!
        
    print("Data 2\n",str)
                    print("*************")
    
    
    //Success
    if (dataNew != nil && response.response?.statusCode == 200) {
        self.sLogin(username: username, password: password)
     //self.displayAlertMessage(message: "awesome!")
    }
    else if (dataNew != nil && response.response?.statusCode == 401){
        self.loadLabel.isHidden = true
    let alert = UIAlertController(title: "Authencation Failed", message: "The  MIDAS ID and password you entered don't match", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
    self.btnLogin.isUserInteractionEnabled = true
    self.btnRegister.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
    //activityIndicator.hide(true, afterDelay: 0)
    }else{
    print("failed 2nd call to SOAP")
    let alert = UIAlertController(title: "Authencation Failed", message: "Request to login is Failing contact your local TA", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
    self.loadLabel.isHidden = true
    self.btnLogin.isUserInteractionEnabled = true
    self.btnRegister.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
    //activityIndicator.hide(true, afterDelay: 2)
    
    }
    }
                }
    }
            else{
    print("failed 1st call to my.odu.edu")
    let alert = UIAlertController(title: "Authencation Failed", message: "ODU Servers are not currently available", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
    //activityIndicator.hide(true, afterDelay: 0)
    self.loadLabel.isHidden = true
    self.btnLogin.isUserInteractionEnabled = true
    self.btnRegister.isUserInteractionEnabled = true
        self.view.isUserInteractionEnabled = true
    }
        }
    }
    }
 
    
    func sLogin(username: String, password: String) {
        
        var user: String?
        let parameters: Parameters = ["username":username , "password": password, "deviceid": Manager.deviceId == nil ? "abc" : Manager.deviceId!, "devicetype" : "iOS"]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/loginNew.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/
            .responseData { response in

                debugPrint("All Response Info: \(response)")

                print("Request:\(response.request)")  // original URL request
                print("Response:\(response.response)") // HTTP URL response
                print("Rsponse data:\(response.data)")

                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {

                    print("Data: \(utf8Text)")
                    print("After data")
                    if let dict = self.convertToDictionary(text: utf8Text) {
                        print(dict as Any)
                        let userFromData = (dict["midas_id"] as! String)
                        if !userFromData.isEmpty {
                            print(userFromData as Any)
                            user = userFromData
                        }


                        print("user from dict:\(user)")

                        if user != nil,user! == username {
                            //self.loadLabel.isHidden = true
                            if(/*self.keyChainUser != nil && */self.rememberCredentials.isOn == true) {
                            self.isUsrSaved = KeychainWrapper.standard.set(user!, forKey: "username")

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
                            let destinationController = storyboard.instantiateViewController(withIdentifier: "tabBarController") as! CustomTabBarController
                            UIApplication.shared.keyWindow?.rootViewController = destinationController

                            Manager.userData = dict
                            if (Manager.userData!["status"] as! String == "Yes") {
                                Manager.userPresent = true
                            } else {
                                Manager.userPresent = false
                            }
                            Manager.triggerNotifications = true
                            Manager.controlLoadAllCells = false
                            self.present(destinationController, animated: true, completion: nil)
                        }
                        else {
                            self.btnLogin.isUserInteractionEnabled = true
                            self.btnRegister.isUserInteractionEnabled = true
                            self.view.isUserInteractionEnabled = true
                            self.loadLabel.isHidden = true
                            self.displayAlertMessage(message: "Invalid username or password")
                            self._username?.text = nil
                            self._password?.text = nil
                            print("invalid username & password")
                        }
                    }
                    else {
                        self.btnLogin.isUserInteractionEnabled = true
                        self.btnRegister.isUserInteractionEnabled = true
                        self.view.isUserInteractionEnabled = true
                        self.loadLabel.isHidden = true
                        self.displayAlertMessage(message: "invalid account details")
                        self._username?.text = nil
                        self._password?.text = nil
                    }
                    
                }
                else {
                    self.btnLogin.isUserInteractionEnabled = true
                    self.btnRegister.isUserInteractionEnabled = true
                    self.view.isUserInteractionEnabled = true
                    self.loadLabel.isHidden = true
                    self.displayAlertMessage(message: "response data is empty")
                    self._username?.text = nil
                    self._password?.text = nil
                }
        }

        
        
        /**********************************************
        
        /*
        if self.credentialSwitch.on == true {
            self.writeCredentials()
        }
        var parameters = Dictionary<String,String>()
        if self.convertedUIN == nil {
            parameters["midasId"] = "\(self.txtStudentID.text!)"
        }
        else
        {
            parameters["uin"] = "\(self.txtStudentID.text!)"
            parameters["password"] = "\(self.txtPassword.text!)"
        }
        Alamofire.Manager.sharedInstance.request(.POST, URL.loginURL, parameters: parameters, encoding: .URL)
            .validate()
            .responseJSON {
                response in
                
                switch response.result{
                case .Success(let data):
                    print("SUCCESS IN REACHING SERVER")
                    let httpMessage: Int = Int((response.response!.statusCode))
                    print("httpmessage",httpMessage)
                    switch httpMessage {
                    case 400:
                        let alert = UIAlertController(title: "Service Call Failed.", message: "Bad Request. Something went wrong try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    case 401:
                        let alert = UIAlertController(title: "Service call Failed.", message: "The request requires user authentication. Please check your credentials", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    case 403:
                        let alert = UIAlertController(title: "Service Call Failed.", message: "Request Forbidden. Something went wrong try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    case 405:
                        let alert = UIAlertController(title: "Service Call Failed.", message: "Method Not Allowed. Something went wrong try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    case 408:
                        let alert = UIAlertController(title: "Service Call Failed.", message: "Request has timed out. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    case 500:
                        let alert = UIAlertController(title: "Service Call Failed.", message: "Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    case 200:
                        //as! AnyObject
                        print("Json Data",data)
                        self.returnData = data
                        self.status = response.response!.statusCode
                        activityIndicator.showWhileExecuting(#selector(LoginViewController.mixedTask), onTarget: self, withObject: nil, animated: true)
                        
                    default:
                        break
                        
                    }
                case .Failure(let error):
                    print("error:\(error)")
                    
                    let alert = UIAlertController(title: "Login Service Call Failed.", message: "Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.btnLogin.userInteractionEnabled = true
                }
                
                
        }
        */
        ***********************************************************************/
    }
    
}

//struct CustomPostEncoding: ParameterEncoding {
//    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
//        var request = try urlRequest.asURLRequest() //try URLEncoding().encode(urlRequest, with: parameters)
//        let temp = self.httpReq as? Data
//        
//        let str = NSString(data: temp!, encoding: String.Encoding.ascii.rawValue)!
//        //request.httpBody =  NSString(data: str, encoding: String.Encoding.utf8.rawValue)!
//        request.httpBody = str.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
//        return request
//    }
//}

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










