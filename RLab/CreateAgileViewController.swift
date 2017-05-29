//
//  CreateAgileViewController.swift
//  TLab
//
//  Created by rahul rachamalla on 5/17/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

class CreateAgileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, NSURLConnectionDelegate  {
 
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var msgBox: UITextView!
    @IBOutlet weak var membersView: UITableView!
    @IBOutlet weak var professorView: UITableView!
    
    var memberDetails: [Dictionary<String,Any>]?
    var profDetails: [Dictionary<String,Any>]?
    var allMembers: [Int:Int] = [0 : 0]
    var allProf: [Int:Int] = [0 : 0]
    var selectedMembers = Set<Int>()
    var selectedProf = Set<Int>()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.msgBox.delegate = self
        self.msgBox.text = "Message"
        self.msgBox.textColor = UIColor.lightGray
        
        self.selectedMembers.removeAll()
        self.selectedProf.removeAll()
        self.allMembers.removeAll()
        self.allProf.removeAll()
        
        let userId = Int(Manager.userData?["userid"] as! String)
     
        let parameters: Parameters = ["userid": userId! ]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/getUserDetails.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseJSON { response in
                
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        self.memberDetails = json["students"] as? [Dictionary<String,Any>]
                        self.profDetails = json["professors"] as? [Dictionary<String,Any>]
                        DispatchQueue.main.async(execute: {
                            self.membersView.reloadData()
                            self.professorView.reloadData()
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
        }
        else if (tableView == self.professorView) {
            if (self.profDetails?.count != nil) {
                return self.profDetails!.count
            }
        }
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
        } else if (tableView == professorView) {
            cell = (tableView.dequeueReusableCell(withIdentifier: "profTableViewCell", for: indexPath) as! ProfTableViewCell)
            (cell as! ProfTableViewCell).professor.text = self.profDetails?[indexPath.row]["username"] as? String
            let id = Int((self.profDetails?[indexPath.row]["userid"] as? String)!)
            self.allProf[indexPath.row] = id
            //(cell as! ProfTableViewCell).userid = id  //layer.setValue(value: userid, forKey: "userid" )
            //print("id in cell: \((cell as! ProfTableViewCell).userid)")
            return cell as! ProfTableViewCell
        }
        
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
        } else {
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
        }
    }
    
    @IBAction func performSaveAction(_ sender: Any) {
        if (self.projectName.text?.isEmpty)! || (self.msgBox.text?.isEmpty)! {
            displayAlertMessage(message: "All fields are required", isOk: false)
            return
        }
        
        if (self.selectedMembers.isEmpty) || (self.selectedProf.isEmpty) {
            displayAlertMessage(message: "select 1 Professor and atleast 1 student", isOk: false)
            return
        }
        
        //let username = Manager.userData?["username"] as! String
        let userid = Int((Manager.userData?["userid"] as? String)!)
        let profid = self.selectedProf.popFirst()!
        let proj = self.projectName.text
        let msg = self.msgBox.text
        var students = [Int](repeating: 0, count: self.selectedMembers.count)
        var i = 0
        for value in self.selectedMembers {
            students[i] = value//self.selectedMembers.popFirst()!
            i += 1
        }
        print("students: \(self.selectedMembers)")
        print("profess: \(self.selectedProf)")
        
      
        let parameters: Parameters = ["userid":userid!, "professorid": profid, "project_name": proj!, "message": msg!, "students": students]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/CreateAgileBoardData.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/
            .responseData { response in
                DispatchQueue.main.async(execute: {
                    //  self.membersView.reloadData()

                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if utf8Text.range(of:"EXCEPTION") != nil{
                        self.displayAlertMessage(message: "Project Not Created. Enter valid names", isOk: false)
                     } else {
                        // Perform ACTION
                        self.displayAlertMessage(message: "Project Created", isOk: true)
                    }
                    
                    //self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
    
  //  @available(iOS 2.0, *)
    func numberOfSections(in tableView: UITableView) -> Int { // Default is 1 if not implemented
    
        return 1;
    }
 
   // @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    // fixed font style. use custom view (UILabel) if you want something different
        if (tableView == membersView) {
            return "Members";
        } else if (tableView == professorView) {
            return "Professors"
        }
        return nil
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
