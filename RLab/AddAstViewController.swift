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
    
    fileprivate var midas_list: [String] = []
    fileprivate var roles_selected = [String]()
    fileprivate var role_list: [String] = ["Teaching Assistant", "Research Assistant"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.astTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.initPicker()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissAddAstViewCntrl(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }

    
    @IBAction func addAssistant(_ sender: Any) {
        if ((self.astTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (self.astPickerField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) {
            self.displayAlertMessage(message: "midas/role cannot be empty")
            return
        }
        if (self.midas_list.contains(self.astTextField.text!)) {
            self.displayAlertMessage(message: "user already added")
            return
        }
        insertAssistantID()
    }
    
    func insertAssistantID() {
        self.midas_list.append(self.astTextField.text!)
        self.roles_selected.append(self.astPickerField.text!)
        let indexPath = IndexPath(row: self.midas_list.count-1, section: 0)
        self.astTableView.beginUpdates()
        self.astTableView.insertRows(at: [indexPath], with: .automatic)
        self.astTableView.endUpdates()
        self.astTextField.text = ""
        self.astPickerField.text = ""
        view.endEditing(true)
    }

    @IBAction func submitAstIDS(_ sender: Any) {
        
        let parameters: Parameters = ["midasIDS": self.midas_list, "roleList": self.roles_selected]
        Alamofire.request(Manager.addAsstService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                
                if let data = response.result.value {
                    if (data.range(of:"Exception") != nil) {
                        self.displayAlertMessage(message: data)
                    } else {
                        self.displayAlertMessage(message: "Added successfully")
                    }
                } else {
                    self.displayAlertMessage(message: "response is nil from server")
                }
        }
        
        if (self.midas_list.count != 0) {
            self.midas_list.removeAll()
            self.roles_selected.removeAll()
            
            for index in 0..<self.midas_list.count {
                self.astTableView.beginUpdates()
                let indexPath = IndexPath(row: 0, section: 0)
                self.astTableView.deleteRows(at: [indexPath], with: .automatic)
                self.astTableView.endUpdates()
            }
            self.astTableView.reloadData()
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
