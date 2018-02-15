//
//  ConfigAssistantsViewController.swift
//  TLab
//
//  Created by Rahul Racha on 2/13/18.
//  Copyright © 2018 handson. All rights reserved.
//

import UIKit
import Alamofire

class ConfigAssistantsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var configSet = Set<String>()
    var indexSet = Set<Int>()
    @IBOutlet weak var configTableView: UITableView!
    @IBOutlet weak var btnDisable: UIButtonX!
    @IBOutlet weak var btnAdmin: UIButtonX!
    @IBOutlet weak var btnDelete: UIButtonX!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let role = Manager.userData?["role"] as! String
        if (role != "Professor" && role != "admin") {
            self.handleAlertAction(title: "Authorization",message: "Unauthorized access", actionTitle: "Ok")
            
        }
        self.btnDisable.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnAdmin.titleLabel?.adjustsFontSizeToFitWidth = true
        self.btnDelete.titleLabel?.adjustsFontSizeToFitWidth = true
        self.configTableView.tableFooterView = UIView(frame: CGRect.zero)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func displayAlertMessage(title: String, message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    func handleAlertAction(title: String, message: String, actionTitle: String, callback: @escaping () -> Void) {
        let alertMsg = UIAlertController(title:title, message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.default, handler:
        { (action) -> Void in
            callback()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertMsg.addAction(confirmAction)
        alertMsg.addAction(cancel)
        present(alertMsg, animated:true, completion: nil)
    }

    
    @IBAction func dismissConfigCntrl(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func disableConfig(_ sender: Any) {
        if (self.configSet.isEmpty) {
            self.displayAlertMessage(title: "Empty", message: "Select users to disable")
            return
        }
        
        self.handleAlertAction(title: "Disable", message: "Assistants disabled can neither access the application nor be monitored by their supervisors. Do you want to proceed?", actionTitle: "Ok", callback: disableUsers)
        
    }
    
    @IBAction func adminConfig(_ sender: Any) {
        if (self.configSet.isEmpty) {
            self.displayAlertMessage(title: "Empty", message: "Select users to grant admin role")
            return
        }
        
        self.handleAlertAction(title: "Disable", message: "Assistants will be granted admin level access. Do you want to proceed?", actionTitle: "Ok", callback: makeAdmins)
        
    }
    
    @IBAction func deleteConfig(_ sender: Any) {
        if (self.configSet.isEmpty) {
            self.displayAlertMessage(title: "Empty", message: "Select users to delete")
            return
        }
        
        self.handleAlertAction(title: "Disable", message: "Assistants will be removed permanently. This may cause log data loss. Do you want to proceed?", actionTitle: "Ok", callback: deleteUsers)
        
    }
    
    
    func disableUsers() {
        let parameters: Parameters = ["midasIDs": Array(self.configSet), "action": "disable"]
        Alamofire.request(Manager.configUserService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                
                if let data = response.result.value {
                    if (data.range(of:"Exception") != nil) {
                        self.displayAlertMessage(title: "Alert", message: data)
                    } else {
                        
                        for index in self.indexSet {
                            Manager.studentDetails?.remove(at: index)
                        }
                        self.configTableView.reloadData()
                        self.displayAlertMessage(title: "Success", message: "Selected assistants are disabled!")
                    }
                }
        }
    }
    
    func makeAdmins() {
        let parameters: Parameters = ["midasIDs": Array(self.configSet), "action": "admin"]
        Alamofire.request(Manager.configUserService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                
                if let data = response.result.value {
                    if (data.range(of:"Exception") != nil) {
                        self.displayAlertMessage(title: "Alert", message: data)
                    } else {
                        
                        for index in self.indexSet {
                            Manager.studentDetails?.remove(at: index)
                        }
                        self.configTableView.reloadData()
                        self.displayAlertMessage(title: "Success", message: "Selected assistants are admins now!")
                    }
                }
        }
    }
    
    func deleteUsers() {
        let parameters: Parameters = ["midasIDs": Array(self.configSet), "action": "delete"]
        Alamofire.request(Manager.configUserService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                
                if let data = response.result.value {
                    if (data.range(of:"Exception") != nil) {
                        self.displayAlertMessage(title: "Alert", message: data)
                    } else {
                        
                        for index in self.indexSet {
                            Manager.studentDetails?.remove(at: index)
                        }
                        self.configTableView.reloadData()
                        self.displayAlertMessage(title: "Success", message: "Selected assistants are deleted!")
                    }
                }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Manager.studentDetails != nil {
            return Manager.studentDetails!.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "configCell", for: indexPath) as! ConfigTableViewCell
        cell.midasLabelField.text = Manager.studentDetails?[indexPath.row]["midas_id"] as? String
        cell.nameLabelField.text = Manager.studentDetails?[indexPath.row]["first_name"] as? String
        return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! ConfigTableViewCell
        currentCell.btnCheckmark.image =  #imageLiteral(resourceName: "icons8-checked-checkbox-filled-100")
        self.configSet.insert(Manager.studentDetails![indexPath.row]["midas_id"] as! String)
        self.indexSet.insert(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! ConfigTableViewCell
        currentCell.btnCheckmark.image =  #imageLiteral(resourceName: "icons8-unchecked-checkbox-100")
        self.configSet.remove(Manager.studentDetails![indexPath.row]["midas_id"] as! String)
        self.indexSet.remove(indexPath.row)
    }

}
