//
//  UpdateAgileViewController.swift
//  TLab
//
//  Created by rahul rachamalla on 5/21/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

class UpdateAgileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, NSURLConnectionDelegate {
    
    
    @IBOutlet weak var logTableView: UITableView!
    @IBOutlet weak var newMessage: UITextView!
    var logDetails: [Dictionary<String,Any>]?
    var projectName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("name pro: \(projectName)")
        self.newMessage.delegate = self
        self.newMessage.text = "New"
        self.newMessage.textColor = UIColor.lightGray
        
        // Do any additional setup after loading the view.
        if (self.projectName != nil) {
            let parameters: Parameters = ["projname":self.projectName!]
            Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/GetUpdateLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
                .responseJSON { response in
                    
                    if let data = response.data {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                            self.logDetails = json["proj_updates"] as? [Dictionary<String,Any>]
                            DispatchQueue.main.async(execute: {
                                self.logTableView.reloadData()
                            })
                            
                        }
                        catch{
                            print("error serializing JSON: \(error)")
                        }
                    }
            }
        }
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "New"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func dismissCreateCon() {
        Manager.controlData = true
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.logDetails != nil {
            return self.logDetails!.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateTableViewCell", for: indexPath) as! UpdateTableViewCell
        // Configure the cell...
        
        cell.author.text = (self.logDetails?[indexPath.row]["username"] as? String)! + " " + (self.logDetails?[indexPath.row]["time_posted"] as? String)!
        cell.logMessage.text = self.logDetails?[indexPath.row]["message"] as? String
        
        return cell
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // fixed font style. use custom view (UILabel) if you want something different
        
        return "Message Log"
    }
    
    
    @IBAction func updateMessage(_ sender: Any) {
        if (self.newMessage.text.isEmpty) {
            displayAlertMessage(message: "Message cannot be empty", isOk: false)
        }
        
        let userid = Int((Manager.userData?["userid"] as? String)!)
        let parameters: Parameters = ["userid":userid!, "projname": self.projectName!, "update": self.newMessage.text]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/newUpdate.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/
            .responseData { response in
                DispatchQueue.main.async(execute: {
                    
                    if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                        print("Data: \(utf8Text)")
                        //if utf8Text.range(of:"EXCEPTION") != nil{
                        //    self.displayAlertMessage(message: "Project Not Created. Enter valid names", isOk: false)
                        // } else {
                        // Perform ACTION
                        self.displayAlertMessage(message: "Project Created", isOk: true)
                        //}
                        
                        //self.dismiss(animated: true, completion: nil)
                    } else {
                        self.displayAlertMessage(message: "New Message Not Updated", isOk: false)
                    }
                })
        }
        
    }
    
}
