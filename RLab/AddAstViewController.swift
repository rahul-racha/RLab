//
//  AddAstViewController.swift
//  TLab
//
//  Created by Rahul Racha on 1/28/18.
//  Copyright © 2018 handson. All rights reserved.
//

import UIKit
import Alamofire

class AddAstViewController: UIViewController {

    @IBOutlet weak var astTableView: UITableView!
    @IBOutlet weak var astTextField: UITextField!
    @IBOutlet weak var astPickerField: UITextField!
    @IBOutlet weak var astEmailField: UITextField!
    @IBOutlet weak var astFirstName: UITextField!
    @IBOutlet weak var astLastName: UITextField!
    @IBOutlet weak var tableTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnBottomConstraint: NSLayoutConstraint!
    
    fileprivate var midas_list: [String] = []
    fileprivate var roles_selected = [String]()
    fileprivate var mail_list = [String]()
    fileprivate var fname_list = [String]()
    fileprivate var lname_list = [String]()
    fileprivate var role_list: [String] = ["Teaching Assistant", "Research Assistant"]
    var isScroll: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.astTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.initPicker()
        self.isScroll = true
        NotificationCenter.default.addObserver(self, selector: #selector(AddAstViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddAstViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if (self.isScroll == true) {
            adjustHeight(show: true, notification: notification)
            self.isScroll = false
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (self.isScroll == false) {
            adjustHeight(show: false, notification: notification)
            self.isScroll = true
        }
    }
    
    func adjustHeight(show:Bool, notification:NSNotification) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let changeInHeight = (keyboardFrame.height) * (show ? 1 : -1)
        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            self.btnBottomConstraint.constant += changeInHeight
            //if self.viewBox.frame.origin.y == 0{
            //self.viewBox.frame.origin.y += changeInHeight
            //}
        })
    }
    
    @IBAction func dismissAddAstViewCntrl(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
    func isValidMidas(testStr:String) -> Bool {
        let midasRegEx = "^[a-zA-Z]+([0-9]+)*$"
        
        let midasTest = NSPredicate(format:"SELF MATCHES %@", midasRegEx)
        return midasTest.evaluate(with: testStr)
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }

    
    @IBAction func addAssistant(_ sender: Any) {
        if ((self.astTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (self.astPickerField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (self.astEmailField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (self.astFirstName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (self.astLastName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!
            ){
            self.displayAlertMessage(message: "All fields are required")
            return
        }
        
        if (!self.isValidMidas(testStr: self.astTextField.text!)) {
            self.displayAlertMessage(message: "Not a valid midas ID.")
            return
        }
        
        if (!self.isValidEmail(testStr: self.astEmailField.text!)) {
            self.displayAlertMessage(message: "Not a valid email. Eg: abcd@odu.edu")
            return
        }
        
        if (!self.isValidName(testStr: self.astFirstName.text!)) {
            self.displayAlertMessage(message: "First name should contain only letters. Eg: James L'Carter")
            return
        }
        
        if (!self.isValidName(testStr: self.astLastName.text!)) {
            self.displayAlertMessage(message: "Last name should contain only letters. Eg: James L'Carter")
            return
        }
        
        if (self.midas_list.contains(self.astTextField.text!)) {
            self.displayAlertMessage(message: "User already added")
            return
        }
        
        if (self.mail_list.contains(self.astEmailField.text!)) {
            self.displayAlertMessage(message: "Email already added")
            return
        }
        insertAssistantID()
    }
    
    func insertAssistantID() {
        self.midas_list.append(self.astTextField.text!)
        self.roles_selected.append(self.astPickerField.text!)
        self.mail_list.append(self.astEmailField.text!)
        self.fname_list.append(self.astFirstName.text!)
        self.lname_list.append(self.astLastName.text!)
        let indexPath = IndexPath(row: self.midas_list.count-1, section: 0)
        self.astTableView.beginUpdates()
        self.astTableView.insertRows(at: [indexPath], with: .automatic)
        self.astTableView.endUpdates()
        self.astTextField.text = ""
        self.astPickerField.text = ""
        self.astEmailField.text = ""
        self.astFirstName.text = ""
        self.astLastName.text = ""
        view.endEditing(true)
    }

    @IBAction func submitAstIDS(_ sender: Any) {
        if (self.midas_list.count < 1) {
            self.displayAlertMessage(message:"Please add a user")
            return
        }
        let parameters: Parameters = ["midasIDS": self.midas_list, "roleList": self.roles_selected, "mailList": self.mail_list, "fnameList": self.fname_list, "lnameList": self.lname_list]
        Alamofire.request(Manager.addAsstService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                
                if let data = response.result.value {
                    if (data.range(of:"Exception") != nil) {
                        self.displayAlertMessage(message: data)
                    } else {
                        self.displayAlertMessage(message: "Added successfully")
                        if (self.midas_list.count != 0) {
                            self.midas_list.removeAll()
                            self.roles_selected.removeAll()
                            self.mail_list.removeAll()
                            
                            for _ in 0..<self.midas_list.count {
                                self.astTableView.beginUpdates()
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.astTableView.deleteRows(at: [indexPath], with: .automatic)
                                self.astTableView.endUpdates()
                            }
                            self.astTableView.reloadData()
                        }
                    }
                } else {
                    self.displayAlertMessage(message: "response is nil from server")
                }
        }
    }
    
    func initPicker() {
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        self.astPickerField.inputView = pickerView
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.tintColor = UIColor.white
        
        toolBar.backgroundColor = UIColor.black
        
        
        let defaultButton = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddAstViewController.tappedToolBarBtn))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(AddAstViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "select role"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([defaultButton,flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        self.astPickerField.inputAccessoryView = toolBar
    }

}

extension AddAstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return midas_list.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.astTableView.dequeueReusableCell(withIdentifier: "astCell") as! AstTableViewCell
        cell.midasLabel.text = self.midas_list[indexPath.row]
        cell.emailLabel.text = self.mail_list[indexPath.row]
        
        let roleText = self.roles_selected[indexPath.row]
        if (roleText == "Teaching Assistant") {
            cell.roleLabel.text = "T.A"
        } else {
            cell.roleLabel.text = "R.A"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.midas_list.remove(at: indexPath.row)
            self.roles_selected.remove(at: indexPath.row)
            self.mail_list.remove(at: indexPath.row)
            self.fname_list.remove(at: indexPath.row)
            self.lname_list.remove(at: indexPath.row)
            self.astTableView.beginUpdates()
            self.astTableView.deleteRows(at: [indexPath], with: .automatic)
            self.astTableView.endUpdates()
        }
    }
}

extension AddAstViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func donePressed(_ sender: UIBarButtonItem) {
        self.astPickerField.resignFirstResponder()
    }
    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        self.astPickerField.text = "Teaching Assistant"
        self.astPickerField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.role_list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.role_list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.astPickerField.text = self.role_list[row]
    }

}
