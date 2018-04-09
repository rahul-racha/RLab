//
//  DeleteSectionViewController.swift
//  TLab
//
//  Created by Rahul Racha on 4/7/18.
//  Copyright © 2018 handson. All rights reserved.
//

import UIKit
import Alamofire

class DeleteSectionViewController: UIViewController {

    
    @IBOutlet weak var delBtn: UIButtonX!
    @IBOutlet weak var disableBtn: UIButtonX!
    @IBOutlet weak var delSectionTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var sectionDetails = [[String: String]]()
        //= [["crn":"123","course":"abc"],
        //["crn":"133","course":"ybc"]
    //]
    var sectionSet = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.startAnimating()
        let access_level = Manager.userData?["access_level"] as! String
        if (access_level != "super" && access_level != "super_ta" && access_level != "super_ra") {
            self.handleAlertAction(title: "Authorization",message: "Unauthorized access", actionTitle: "Ok")
        }
        self.disableBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.delBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        self.delSectionTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let parameters: Parameters = [:]
        Alamofire.request(Manager.getSecDetailsService,method: .get,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseData { response in
                
                if let data = response.data {
                    do {
                        self.sectionDetails = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:String]]
                        DispatchQueue.main.async(execute: {
                            self.delSectionTableView.reloadData()
                            self.activityIndicator.stopAnimating()
                            
                        })
                        
                    }
                    catch {
                        //self.displayAlertMessage(message: "error serializing JSON: \(error)")
                        print(error)
                    }
                }
        }
        
    }
    
    @IBAction func dismissController(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

    @IBAction func deleteSection(_ sender: Any) {
        if (self.sectionSet.isEmpty) {
            self.displayAlertMessage(title: "Empty", message: "Select sections to delete")
            return
        }
        
        self.handleAlertAction(title: "Delete", message: "Students in the deleted sections are permanently removed from the database. Do you want to proceed?", actionTitle: "Ok", callback: deleteSection)
    }
    
    @IBAction func disableSection(_ sender: Any) {
        if (self.sectionSet.isEmpty) {
            self.displayAlertMessage(title: "Empty", message: "Select sections to disable")
            return
        }
        
        self.handleAlertAction(title: "Disable", message: "Students in the disabled sections are denied access to the application. Do you want to proceed?", actionTitle: "Ok", callback: disableSection)
    }
    
    
    func disableSection() {
        let parameters: Parameters = ["crn": Array(self.sectionSet), "action": "disable"]
        Alamofire.request(Manager.delSectionService ,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                
                if let data = response.result.value {
                    if (data.range(of:"Exception") != nil) {
                        self.displayAlertMessage(title: "Alert", message: data)
                    } else {

                        var cnt = 0
                        while (cnt < self.sectionDetails.count) {
                            if (self.sectionSet.contains((self.sectionDetails[cnt]["crn"])!)) {
                                self.sectionDetails.remove(at: cnt)
                                cnt -= 1
                            }
                            cnt += 1
                        }
                        
                        self.sectionSet.removeAll()
                        self.delSectionTableView.reloadData()
                        self.displayAlertMessage(title: "Success", message: "Selected sections are disabled!")
                    }
                }
        }

    }
    
    func deleteSection() {
        let parameters: Parameters = ["crn": Array(self.sectionSet), "action": "delete"]
        Alamofire.request(Manager.delSectionService, method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                
                if let data = response.result.value {
                    if (data.range(of:"Exception") != nil) {
                        self.displayAlertMessage(title: "Alert", message: data)
                    } else {
                        
                        var cnt = 0
                        while (cnt < self.sectionDetails.count) {
                            if (self.sectionSet.contains((self.sectionDetails[cnt]["crn"])!)) {
                                self.sectionDetails.remove(at: cnt)
                                cnt -= 1
                            }
                            cnt += 1
                        }
                        
                        self.sectionSet.removeAll()
                        self.delSectionTableView.reloadData()
                        self.displayAlertMessage(title: "Success", message: "Selected sections are deleted!")
                    }
                }
        }

    }

    
}

extension DeleteSectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.sectionDetails)
        if self.sectionDetails.count > 0 {
            return self.sectionDetails.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "delSectionCell", for: indexPath) as! DeleteSectionTableViewCell
        cell.crnLabel.text = self.sectionDetails[indexPath.row]["crn"]
        cell.courseLabel.text = self.sectionDetails[indexPath.row]["course"]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! DeleteSectionTableViewCell
        currentCell.selectBox.image =  #imageLiteral(resourceName: "icons8-checked-checkbox-filled-100")
        self.sectionSet.insert(self.sectionDetails[indexPath.row]["crn"]!)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath) as! DeleteSectionTableViewCell
        currentCell.selectBox.image =  #imageLiteral(resourceName: "icons8-unchecked-checkbox-100")
        self.sectionSet.remove(self.sectionDetails[indexPath.row]["crn"]!)
    }

}


