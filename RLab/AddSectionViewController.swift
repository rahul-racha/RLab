//
//  AddSectionViewController.swift
//  TLab
//
//  Created by Rahul Racha on 4/6/18.
//  Copyright © 2018 handson. All rights reserved.
//

import UIKit
import Alamofire

class AddSectionViewController: UIViewController {

    
    @IBOutlet weak var crnTxtField: UITextFieldX!
    @IBOutlet weak var courseTxtField: UITextField!
    @IBOutlet weak var sectionTxtField: UITextField!
    
    @IBOutlet weak var sectionTableView: UITableView!
    
    fileprivate var crn_selected: [String] = []
    fileprivate var course_list: [String] = ["120G", "121G"]
    fileprivate var course_selected: [String] = []
    fileprivate var section_selected: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let access_level = Manager.userData?["access_level"] as! String
        if (access_level != "super" && access_level != "super_ta" && access_level != "super_ra") {
            self.handleAlertAction(title: "Authorization",message: "Unauthorized access", actionTitle: "Ok")
            
        }
        self.sectionTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.initCoursePicker()
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    func handleAlertAction(title: String, message: String, actionTitle: String) {
        let alertMsg = UIAlertController(title:title, message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler:
        { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }


    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func isValidCRN(testStr: String) -> Bool {
        let crnRegEx = "^[0-9]{5,}$"
        let crnTest = NSPredicate(format:"SELF MATCHES %@", crnRegEx)
        return crnTest.evaluate(with: testStr)
    }
    
    func isValidSection(testStr: String) -> Bool {
//        let sectionRegEx = "^$"
//        let sectionTest = NSPredicate(format:"SELF MATCHES %@", sectionRegEx)
//        return sectionTest.evaluate(with: testStr)
        return true
    }
    
    
    @IBAction func addSection(_ sender: Any) {
        if ((self.crnTxtField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! ||
            (self.courseTxtField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! ||
            (self.sectionTxtField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) {
            self.displayAlertMessage(message: "All fields are required")
            return
        }
        if (!self.isValidCRN(testStr: self.crnTxtField.text!)) {
            self.displayAlertMessage(message: "Not a valid CRN")
            return
        }
        
        if (!self.isValidSection(testStr: self.sectionTxtField.text!)) {
            self.displayAlertMessage(message: "Not a valid section name.")
            return
        }
        
        self.insertSection()
    }
    
    func insertSection() {
        self.crn_selected.append(self.crnTxtField.text!)
        self.course_selected.append(self.courseTxtField.text!)
        self.section_selected.append(self.sectionTxtField.text!)
        let indexPath = IndexPath(row: self.crn_selected.count-1, section: 0)
        self.sectionTableView.beginUpdates()
        self.sectionTableView.insertRows(at: [indexPath], with: .automatic)
        self.sectionTableView.endUpdates()
        self.crnTxtField.text = ""
        self.courseTxtField.text = ""
        self.sectionTxtField.text = ""
        view.endEditing(true)
    }
    
    
    @IBAction func resetEnteredInformation(_ sender: Any) {
        while (self.crn_selected.count > 0) {
            var indexPath = IndexPath(row: 0, section: 0)
            self.crn_selected.remove(at: indexPath.row)
            self.course_selected.remove(at: indexPath.row)
            self.section_selected.remove(at: indexPath.row)
            self.sectionTableView.beginUpdates()
            self.sectionTableView.deleteRows(at: [indexPath], with: .automatic)
            self.sectionTableView.endUpdates()
        }
    }
    
    @IBAction func submitDetails(_ sender: Any) {
        if (self.crn_selected.count < 1) {
            self.displayAlertMessage(message:"Please add a section")
            return
        }
        
        let parameters: Parameters = ["crn": self.crn_selected, "course": self.course_selected, "description": self.section_selected]
        Alamofire.request(Manager.addNewSecService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                
                if let data = response.result.value {
                    if (data.range(of:"Exception") != nil) {
                        self.displayAlertMessage(message: data)
                    } else {
                        self.displayAlertMessage(message: "Added successfully")
                        if (self.crn_selected.count != 0) {
                            self.crn_selected.removeAll()
                            self.course_selected.removeAll()
                            self.section_selected.removeAll()
                            for _ in 0..<self.crn_selected.count {
                                self.sectionTableView.beginUpdates()
                                let indexPath = IndexPath(row: 0, section: 0)
                                self.sectionTableView.deleteRows(at: [indexPath], with: .automatic)
                                self.sectionTableView.endUpdates()
                            }
                            
                            self.sectionTableView.reloadData()
                        }
                    }
                } else {
                    self.displayAlertMessage(message: "response is nil from server")
                }
        }
    }
    
    

}

extension AddSectionViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func initCoursePicker() {
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        pickerView.tag = 1
        self.courseTxtField.inputView = pickerView
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.tintColor = UIColor.white
        
        toolBar.backgroundColor = UIColor.black
        
        
        let defaultButton = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddSectionViewController.tappedToolBarBtn))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(AddSectionViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 14)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "select course"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([defaultButton,flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        self.courseTxtField.inputAccessoryView = toolBar
    }
    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        self.courseTxtField.text = "121G"
        self.courseTxtField.resignFirstResponder()
    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        self.courseTxtField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.course_list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.course_list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.courseTxtField.text = self.course_list[row]
    }

}

extension AddSectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.crn_selected.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionCell") as! SectionTableViewCell
        cell.crnLabel.text = self.crn_selected[indexPath.row]
        cell.courseLabel.text = self.course_selected[indexPath.row]
        cell.sectionLabel.text = self.section_selected[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.crn_selected.remove(at: indexPath.row)
            self.course_selected.remove(at: indexPath.row)
            self.section_selected.remove(at: indexPath.row)
            self.sectionTableView.beginUpdates()
            self.sectionTableView.deleteRows(at: [indexPath], with: .automatic)
            self.sectionTableView.endUpdates()
        }
    }
    
    
}
