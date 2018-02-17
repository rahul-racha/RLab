//
//  EditProfileViewController.swift
//  TLab
//
//  Created by Rahul Racha on 2/12/18.
//  Copyright © 2018 handson. All rights reserved.
//

import UIKit
import Alamofire

class EditProfileViewController: UIViewController {

    @IBOutlet weak var fnameTextField: UITextField!
    @IBOutlet weak var lnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        self.initFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
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
    
    func initFields() {
        print(String(describing: Manager.userData?["first_name"] as! String))
        self.fnameTextField.placeholder = String(describing: Manager.userData?["first_name"] as! String)
        self.lnameTextField.placeholder = String(describing: Manager.userData?["last_name"] as! String)
        self.emailTextField.placeholder = String(describing: Manager.userData?["email"] as! String)
        self.usernameTxtField.placeholder = String(describing: Manager.userData?["username"] as! String)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidName(testStr:String) -> Bool {
        let nameRegEx = "^[a-zA-Z]+([ '-][a-zA-Z]+)*$"
        
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: testStr)
    }
    
    func isValidUsername(testStr:String) -> Bool {
        let nameRegEx = "^[a-zA-Z]+$"
        
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegEx)
        return nameTest.evaluate(with: testStr)
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }

    
    @IBAction func dismissEditPfCntrl(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateFields(_ sender: Any) {
        
        if ((self.fnameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && (self.lnameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && (self.emailTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && (self.usernameTxtField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!
            ) {
            self.displayAlertMessage(message: "None of the entries are filled")
            return
        }
        
        if (!(self.emailTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && !self.isValidEmail(testStr: self.emailTextField.text!)) {
            self.displayAlertMessage(message: "Not a valid email. Eg: abcd@odu.edu")
            return
        }
        
        if (!(self.fnameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && !self.isValidName(testStr: self.fnameTextField.text!)) {
            self.displayAlertMessage(message: "First name should contain only letters. Eg: James L'Carter")
            return
        }
        
        if (!(self.lnameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && !self.isValidName(testStr: self.lnameTextField.text!)) {
            self.displayAlertMessage(message: "Last name should contain only letters. Eg: James L'Carter")
            return
        }
        
        if (!(self.usernameTxtField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! && !self.isValidUsername(testStr: self.usernameTxtField.text!)) {
            self.displayAlertMessage(message: "User name should contain only letters with no spaces. Eg: James")
            return
        }
        
        let fText = (!(self.fnameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) ? self.fnameTextField.text! : self.fnameTextField.placeholder!
        let lText = (!(self.lnameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) ? self.lnameTextField.text! : self.lnameTextField.placeholder!
        let eText = (!(self.emailTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) ? self.emailTextField.text! : self.emailTextField.placeholder!
        let unameTxt = (!(self.usernameTxtField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) ? self.usernameTxtField.text! : self.usernameTxtField.placeholder!
        
        let parameters: Parameters = ["fname": fText, "lname": lText, "email": eText, "username": unameTxt, "midasID": String(describing: Manager.userData?["midas_id"] as! String)]
        Alamofire.request(Manager.updateProfileService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                if let data = response.result.value {
                    if (data.range(of:"Exception") != nil) {
                        self.displayAlertMessage(message: data)
                    } else {
                        self.displayAlertMessage(message: "Updated successfully")
                        
                        self.fnameTextField.placeholder = fText
                        self.lnameTextField.placeholder = lText
                        self.emailTextField.placeholder = eText
                        self.usernameTxtField.placeholder = unameTxt
                        
                        self.fnameTextField.text = ""
                        self.lnameTextField.text = ""
                        self.emailTextField.text = ""
                        self.usernameTxtField.text = ""
                        
                        Manager.userData?["first_name"] = fText
                        Manager.userData?["last_name"] = lText
                        Manager.userData?["email"] = eText
                        Manager.userData?["username"] = unameTxt
                        
                    }
                }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
