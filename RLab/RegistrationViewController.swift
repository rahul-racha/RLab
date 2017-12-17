//
//  RegistrationViewController.swift
//  TLab
//
//  Created by Rahul Racha on 10/6/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

class RegistrationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var retypePwd: UITextField!
    
    @IBOutlet weak var role: UITextField!
    
    
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var submitButton: UIButton!
    
    var pickRole = ["T.A", "R.A", "Professor"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.initPicker()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let window = self.view.window?.frame {

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

    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    func displayConfirmation(message: String) {
        
        let confirmationAlert = UIAlertController(title: "Confirmation", message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        confirmationAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        
        present(confirmationAlert, animated: true, completion: nil)
        
    }
    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        
        self.role.text = "T.A"
        
        self.role.resignFirstResponder()
    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        
        self.role.resignFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickRole.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickRole[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.role.text = self.pickRole[row]
    }
    
    func initPicker() {
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        self.role.inputView = pickerView
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.tintColor = UIColor.white
        
        toolBar.backgroundColor = UIColor.black
        
        
        let defaultButton = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.plain, target: self, action: #selector(RegistrationViewController.tappedToolBarBtn))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(RegistrationViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Pick the role"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([defaultButton,flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        self.role.inputAccessoryView = toolBar
    }
    
    @IBAction func dismissCntrl(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func clearFields(_ sender: Any) {
        self.username.text = nil
        self.password.text = nil
        self.retypePwd.text = nil
        self.role.text = nil
    }
    
    @IBAction func submitForm(_ sender: Any) {
        if (self.username.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Please enter the username.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        } else if (self.password.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Please enter your password.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        } else if !(self.isPasswordValid(password: (self.password?.text)!)) {
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Password length should be atleast 8. Include One Alphabet, One digit and One Special Character in Password.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
        } else if ((self.retypePwd.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (self.retypePwd.text?.characters.count != self.password.text?.characters.count && self.retypePwd.text != self.password.text)) {
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Confirmed password not matched please try again.",
                                                  delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        } else if (self.role.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            var alert : UIAlertView = UIAlertView(title: "Oops!", message: "Please choose your role.",
                                      delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            
        } else {
            var isResponseSuccess: Bool?
            self.username.text = self.username.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.password.text = self.password.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            
            let parameters: Parameters = ["username": self.username.text!, "password": self.password.text!, "role": self.role.text!]
            print(parameters)
            Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/registerUser.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseData { response in
                DispatchQueue.main.async(execute: {
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)")
                        if (utf8Text.range(of:"username exists") != nil) {
                            self.displayAlertMessage(message: "username exists. Try a different one")
                            isResponseSuccess = false
                        } /*else if (utf8Text.range(of:"invalid key") != nil) {
                            self.displayAlertMessage(message: "entered invalid key")
                            isResponseSuccess = false
                        } */else if (utf8Text.range(of:"success") != nil) {
                            self.displayConfirmation(message: "You are registered :)")
                            isResponseSuccess = true
                            
                        } else {
                            // Perform ACTION
                            self.displayAlertMessage(message: "Something went wrong :(")
                            isResponseSuccess = false
                        }
                        
                    } else {
                        self.displayAlertMessage(message: "Server response is empty")
                        isResponseSuccess = false
                    }
                    
                })
            }
        }
        
        
    }
    
    func isPasswordValid(password : String) -> Bool{
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[$@$#!%*?&])[A-Za-z0-9\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    

}
