//
//  LogViewController.swift
//  TLab
//
//  Created by rahul rachamalla on 3/8/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

class LogViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,NSURLConnectionDelegate {
    
    @IBOutlet weak var logTableView: UITableView!
    var userName: String?
    var userId: Int?
    var status: Bool?
    var daysLog: [Dictionary<String,Any>]?
    override func viewDidLoad() {
        super.viewDidLoad()
     
        // Do any additional setup after loading the view.
        print("log: \(self.userName)!")
        print("log: \(self.userId)!")
        
        let parameters: Parameters = ["userid":userId!]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/GetAvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseJSON { response in
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        self.daysLog = json["total_time"] as? [Dictionary<String,Any>]
                        print("days111 \(self.daysLog)")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

   /* func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.daysLog != nil {
            return self.daysLog!.count
        }
        
        return 0
    }
    
  /*  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 40;//Choose your custom row height
    }*/

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logViewCell", for: indexPath) as! LogViewCell
        
        if (self.daysLog != nil) {
            // Configure the cell...
            if(indexPath.row%2 == 0)
            {
                //print("adfsaff")
                //cell.backgroundView?.backgroundColor = UIColor.darkGray
                if self.status == true {
                cell.backgroundColor = UIColor.green
                } else {
                    cell.backgroundColor = UIColor.gray
                }
            }
            else{
                //cell.backgroundView?.backgroundColor = UIColor.cyan
                cell.backgroundColor = UIColor.white
            }
            print("dayslog: \(self.daysLog?[indexPath.row]["hours"] as? Int)")
            cell.dateLabel.text=self.daysLog?[indexPath.row]["current_date"] as? String
            cell.hoursLabel.text = (self.daysLog?[indexPath.row]["hours"]! as AnyObject).stringValue
            cell.minutesLabel.text = (self.daysLog?[indexPath.row]["minutes"]! as AnyObject).stringValue
            
        }
        return cell
    }
    
    
}
