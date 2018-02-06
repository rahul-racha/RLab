//
//  CreateAgileViewController.swift
//  TLab
//
//  Created by rahul rachamalla on 5/17/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

class CreateAgileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate,UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, NSURLConnectionDelegate  {
 
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var msgBox: UITextView!
    @IBOutlet weak var profTextField: UITextField!
    
    @IBOutlet weak var membersView: UITableView!
    //@IBOutlet weak var professorView: UITableView!
    
    var memberDetails: [Dictionary<String,Any>]?
    var profDetails: [Dictionary<String,Any>]?
    
    var allMembers: [Int:Int] = [0 : 0]
    //var allProf: [Int:Int] = [0 : 0]
    var selectedMembers = Set<Int>()
    //var selectedProf = Set<Int>()
    var pickOption = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.msgBox.delegate = self
        self.msgBox.text = "Message"
        self.msgBox.textColor = UIColor.lightGray
        
        self.selectedMembers.removeAll()
        //self.selectedProf.removeAll()
        self.allMembers.removeAll()
        //self.allProf.removeAll()
        /*if let roleVar = Manager.userData?["role"] as? String {
            if (roleVar == "Professor") {
                self.profTextField.isHidden = true
            } else {
                self.profTextField.isHidden = false
            }
            
        }*/
        
        let userId = Int(Manager.userData?["userid"] as! String)
     
        let parameters: Parameters = ["userid": userId! ]
        Alamofire.request(Manager.getUserDetailsService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseJSON { response in
                
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        self.memberDetails = json["students"] as? [Dictionary<String,Any>]
                        self.profDetails = json["professors"] as? [Dictionary<String,Any>]

                        DispatchQueue.main.async(execute: {
                            self.addPickerDetails()
                            self.membersView.reloadData()
                            //self.professorView.reloadData()
                        })
                        
                    }
                    catch{
                        self.displayAlertMessage(message: "error serializing JSON: \(error)", isOk: false)
                    }
                }
        }
    
        // Do any additional setup after loading the view.
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.initProfPicker()
    }
    
    func displayAlertMessage(message: String, isOk: Bool) {
        let alertMsg = UIAlertController(title:"Message", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        //let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        //alertMsg.addAction(confirmAction)
        alertMsg.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            //run your function here
            if (isOk == true) {
                self.dismissCreateCon()
            }
        }))
        alertMsg.view.setNeedsLayout()
        present(alertMsg, animated:true, completion: nil)
        //self.parent?.parent?.dismiss(animated: true, completion: nil)
    }
    
    func displayVanishingAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 0.8
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func addPickerDetails() {
        
        if (self.profDetails != nil) {
            for i in 0..<(self.profDetails?.count)! {
                if let name = self.profDetails?[i]["username"] as? String {
                    self.pickOption.append(name)
                    /*
                    if let role = Manager.userData?["role"] as? String {
                        if (role == "Professor") {
                            print(self.memberDetails)
                            print((self.memberDetails?.count)!)
                            //if (self.memberDetails != nil) {
                                self.memberDetails?.append((self.profDetails?[i])!)
                                //self.memberDetails?[(self.memberDetails?.count)!]["username"] = name
                                //self.memberDetails?[(self.memberDetails?.count)!]["userid"] = Int((self.profDetails?[i]["userid"] as? String)!)
                            //} else {
                            //    self.memberDetails?[0]["username"] = name
                            //    self.memberDetails?[0]["userid"] = Int((self.profDetails?[i]["userid"] as? String)!)
                            //}
                        }
                    }
                    */
                }
            }
        
        }

        
    }
    
    func dismissCreateCon() {
        //self.dismiss(animated: true, completion: nil)
        //let agileCon = AgileViewController()
        //agileCon.reload = true
        //let agileCon = self.navigationController?.viewControllers[2] as! AgileViewController
        //agileCon.reload = true
        Manager.controlData = true
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Message"
            textView.textColor = UIColor.lightGray
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == self.membersView) {
        if (self.memberDetails?.count != nil) {
            return self.memberDetails!.count
        }
        }/*
        else if (tableView == self.professorView) {
            if (self.profDetails?.count != nil) {
                return self.profDetails!.count
            }
        }*/
        return 0
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        if (self.memberDetails?.count != nil) {
        if (tableView == membersView) {
            
            cell = (tableView.dequeueReusableCell(withIdentifier: "memberTableViewCell", for: indexPath) as! MemberTableViewCell)
            (cell as! MemberTableViewCell).member.text = self.memberDetails?[indexPath.row]["username"] as? String
            let id = Int((self.memberDetails?[indexPath.row]["userid"] as? String)!)
            //(cell as! MemberTableViewCell).userid = id //layer.setValue(value: userid, forKey: "userid" )
            //print("id in cell: \((cell as! MemberTableViewCell).userid)")
            self.allMembers[indexPath.row] = id
            return cell as! MemberTableViewCell
        } /*else if (tableView == professorView) {
            cell = (tableView.dequeueReusableCell(withIdentifier: "profTableViewCell", for: indexPath) as! ProfTableViewCell)
            (cell as! ProfTableViewCell).professor.text = self.profDetails?[indexPath.row]["username"] as? String
            let id = Int((self.profDetails?[indexPath.row]["userid"] as? String)!)
            self.allProf[indexPath.row] = id
            //(cell as! ProfTableViewCell).userid = id  //layer.setValue(value: userid, forKey: "userid" )
            //print("id in cell: \((cell as! ProfTableViewCell).userid)")
            return cell as! ProfTableViewCell
        }*/
        
        }

    
        return cell!;
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if (tableView == membersView) {
            //let cell = (tableView.dequeueReusableCell(withIdentifier: "memberTableViewCell", for: indexPath) as! MemberTableViewCell)
            if membersView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
                membersView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
                print("id :  \(self.allMembers[indexPath.row])") //\((cell as! MemberTableViewCell).userid)")
                self.selectedMembers.remove(self.allMembers[indexPath.row]!)
            } else {
                membersView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                print("id : \(self.allMembers[indexPath.row])") // \((cell as! MemberTableViewCell).userid)")
                self.selectedMembers.insert(self.allMembers[indexPath.row]!)
            }
        } /*else {
           // let cell = (tableView.dequeueReusableCell(withIdentifier: "profTableViewCell", for: indexPath) as! ProfTableViewCell)
            if professorView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
                professorView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
                print("id :  \(self.allProf[indexPath.row])")
                self.selectedProf.remove(self.allProf[indexPath.row]!)
            } else {
                professorView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                //self.selectedProf.insert(cell.userid!)
                print("id :  \(self.allProf[indexPath.row])")
                self.selectedProf.insert(self.allProf[indexPath.row]!)
            }
        }*/
    }
    
    @IBAction func performSaveAction(_ sender: Any) {
        if (self.projectName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! || (self.msgBox.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)! {
            displayAlertMessage(message: "All fields are required", isOk: false)
            return
        }
        
        if ((self.profTextField?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)!) {
            displayAlertMessage(message: "select a Professor", isOk: false)
            return
        }
        
        if (self.selectedMembers.isEmpty) {
            displayAlertMessage(message: "select atleast 1 Member", isOk: false)
            return
        }
        
        //let username = Manager.userData?["username"] as! String
        let userid = Int((Manager.userData?["userid"] as? String)!)
        var profid = -1
        
        /*if let roleVar = Manager.userData?["role"] as? String {
        if (roleVar == "Professor") {
            profid = Int((Manager.userData?["userid"] as? String)!)!
        } else {*/
            let pickerName = self.profTextField.text
            if (self.profDetails != nil) {
                for i in 0..<(self.profDetails?.count)! {
                    if let profname = self.profDetails?[i]["username"] as? String {
                    if (pickerName == profname) {
                        profid = Int((self.profDetails?[i]["userid"] as? String)!)!
                        break
                    }
                }
                }
            }
            //}
        //}
        
        
        //self.selectedProf.popFirst()!
        let proj = self.projectName.text
        let msg = self.msgBox.text
        var students = [Int](repeating: 0, count: self.selectedMembers.count)
        var i = 0
        for value in self.selectedMembers {
            students[i] = value
            i += 1
        }
        print("students: \(self.selectedMembers)")
      
        let parameters: Parameters = ["userid":userid!, "professorid": profid, "project_name": proj!, "message": msg!, "students": students]
        Alamofire.request(Manager.createAgileService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/
            .responseData { response in
                DispatchQueue.main.async(execute: {
                    //  self.membersView.reloadData()

                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"EXCEPTION") != nil{
                        self.displayAlertMessage(message: "Project Not Created. Enter valid names", isOk: false)
                     } else {
                        // Perform ACTION
                        //self.displayAlertMessage(message: "Project Created", isOk: true)
                        self.displayVanishingAlert(message: "Project Created")
                        //self.dismissCreateCon()
                    }
                    
                    //self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
    @available(iOS 2.0, *)
    func numberOfSections(in tableView: UITableView) -> Int { // Default is 1 if not implemented
    
        return 1;
    }
 
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    // fixed font style. use custom view (UILabel) if you want something different
        if (tableView == membersView) {
            return "Members";
        } /*else if (tableView == professorView) {
            return "Professors"
        }*/
        return nil
    }
    
    func initProfPicker() {
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        self.profTextField.inputView = pickerView
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        
        toolBar.tintColor = UIColor.white
        
        toolBar.backgroundColor = UIColor.black
        
        
        let defaultButton = UIBarButtonItem(title: "Default", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreateAgileViewController.tappedToolBarBtn))
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(CreateAgileViewController.donePressed))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 11)
        
        label.backgroundColor = UIColor.clear
        
        label.textColor = UIColor.white
        
        label.text = "Select the Instructor"
        
        label.textAlignment = NSTextAlignment.center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([defaultButton,flexSpace,textBtn,flexSpace,doneButton], animated: true)
        
        self.profTextField.inputAccessoryView = toolBar
    }
    
    func donePressed(_ sender: UIBarButtonItem) {
        
        self.profTextField.resignFirstResponder()
        
    }
    
    func tappedToolBarBtn(_ sender: UIBarButtonItem) {
        
        self.profTextField.text = "Ajay Gupta"
        
        self.profTextField.resignFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.profTextField.text = pickOption[row]
    }


}
