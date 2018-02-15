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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configTableView.tableFooterView = UIView(frame: CGRect.zero)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlertMessage(title: String, message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    func handleAlertAction(title: String, message: String, actionTitle: String, callback: @escaping () -> Void) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
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
    
    @IBAction func saveConfig(_ sender: Any) {
        if (self.configSet.isEmpty) {
            self.displayAlertMessage(title: "Empty", message: "Select users to disable")
            return
        }
        
        self.handleAlertAction(title: "Disable", message: "Assistants disabled can neither access the application nor be monitored by their supervisors. Do you want to proceed?", actionTitle: "Ok", callback: disableUsers)
        
    }
    
    func disableUsers() {
        
        let parameters: Parameters = ["midasIDS": Array(self.configSet), "action": "disable"]
        Alamofire.request(Manager.configUserService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                
                if let data = response.result.value {
                    if (data.range(of:"Exception") != nil) {
                        
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
