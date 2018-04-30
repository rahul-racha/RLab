//
//  AgileViewController.swift
//  TLab
//
//  Created by rahul rachamalla on 3/13/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire
import Foundation

//private let reuseIdentifier = "Cell"

class AgileViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate/*, UICollectionViewDataSourcePrefetching*/, NSURLConnectionDelegate {
    
    
    @IBOutlet weak var agileCollectionViewOutlet: UICollectionView!
    @IBOutlet weak var toggleAssistant: UISwitch!
    let stopMonitoringKey = "com.Tlab.stopMonitoring"
    @IBOutlet weak var menuBtnItem: UIBarButtonItem!
    var agileBoardData : [Dictionary<String,Any>]?
    var row_id = 0
    var userName: String?
    var projectName: String?
    var reload: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print ("I am HERE in View")
        toggleAssistant.addTarget(self, action: #selector(AvailabilityController.viewDidLoad), for: UIControlEvents.valueChanged)
        self.menuBtnItem.target = revealViewController()
        self.menuBtnItem.action = #selector(SWRevealViewController.revealToggle(_:))
        
        Manager.controlData = false
        
//        var userId: Int?
//        if(Manager.userData != nil && Manager.userData!["role"] as! String == "Professor") {
//            self.toggleAssistant.isHidden = false
//            if(self.toggleAssistant.isOn == true) {
//                userId = 6
//                Manager.toggleAssistant = true
//            }else {
//                userId = 14
//                Manager.toggleAssistant = false
//            }
//        }
//        else {
//            self.toggleAssistant.isHidden = true
//            userId = Int(Manager.userData?["userid"] as! String)
//        }
        self.toggleAssistant.isHidden = true
        var proxyUser = 0
        let role = Manager.userData?["role"] as! String
        let access_level = Manager.userData?["access_level"] as! String
        
        if (role == "Professor" && access_level == "super") {
            self.toggleAssistant.isHidden = false
            if (self.toggleAssistant.isOn == true) {
                proxyUser = Int(Manager.extras?["dummy_ra_ID"] as! String)!
                Manager.toggleAssistant = true
            }else {
                proxyUser = Int(Manager.extras?["dummy_ta_ID"] as! String)!
                Manager.toggleAssistant = false
            }
        } else if (role == "Professor" && access_level == "super_ra") {
            proxyUser = Int(Manager.extras?["dummy_ra_ID"] as! String)!
        } else if (role == "Professor" && access_level == "super_ta") {
            proxyUser = Int(Manager.extras?["dummy_ta_ID"] as! String)!
        } else {
            proxyUser = Int(Manager.userData?["userid"] as! String)!
        }

        
        let parameters: Parameters = ["userid":proxyUser]
        Alamofire.request(Manager.agileBoardService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/.responseJSON { response in
            
            if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                    self.agileBoardData = json["agileboarddata"] as? [Dictionary<String,Any>]
                    DispatchQueue.main.async(execute: {
                        self.agileCollectionViewOutlet.reloadData()
                    })
                    
                }
                catch{
                    print("error serializing JSON: \(error)")
                }
            }
        }
        
        
        
        /* if let tabHeight = self.tabBarController?.tabBar.frame.height{
         self.agileCollectionViewOutlet?.contentInset = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 10, bottom: tabHeight, right: 10)
         }else{
         self.agileCollectionViewOutlet?.contentInset = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 10, bottom: 50, right: 10)
         }*/
        
        // Register cell classes
        //self.agileCollectionViewOutlet!.register(UINib.init(nibName: "AgileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "agileCollectionViewCell")
        
        
        // Do any additional setup after loading the view.
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func refreshView(_ sender: Any) {
        viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("I am bak")
        if (Manager.controlData! == true) {
            print("I am in ViewAppear")
            self.viewDidLoad()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if self.agileBoardData == nil {
            return 1
        } else {
            return self.agileBoardData!.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "agileCollectionViewCell", for: indexPath) as! AgileCollectionViewCell
        
        
        cell.layoutIfNeeded()
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 3.0
        cell.layer.borderColor = UIColor.clear.cgColor
        //cell.layer.masksToBounds = true
        
        if (self.agileBoardData != nil) {
            var students = [String]()
            cell.profAndProj.text = (self.agileBoardData?[indexPath.row]["project_name"] as? String)! + " under " + (self.agileBoardData?[indexPath.row]["professor_name"] as? String)!
            cell.author.text = "-" + (self.agileBoardData?[indexPath.row]["username"] as? String)! + " at " + (self.agileBoardData?[indexPath.row]["time_posted"] as? String)!
            cell.update.text=self.agileBoardData?[indexPath.row]["message"] as? String
            students=(self.agileBoardData?[indexPath.row]["students"] as? [String])!
            cell.members.text = ""
            for s in 0 ..< students.count {
                if (s != students.count-1) {
                    cell.members.text = cell.members.text?.appending(students[s])
                    cell.members.text = cell.members.text?.appending("\n")
                } else {
                    cell.members.text = cell.members.text?.appending(students[s])
                }
                
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //let cell = collectionView.cellForItem(at: indexPath) as! AgileCollectionViewCell
        self.projectName = (self.agileBoardData?[indexPath.row]["project_name"] as? String)!
        self.performSegue(withIdentifier: "UpdateAgileViewController", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UpdateAgileViewController"{
            let destinationViewController = segue.destination as! UpdateAgileViewController
            destinationViewController.projectName = self.projectName
        }
    }
    
}

/*extension AgileViewController: UICollectionViewDelegateFlowLayout{
 
 func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
 var collectionViewSize = collectionView.frame.size
 //collectionViewSize.width = collectionViewSize.width/2
 collectionViewSize.height = collectionViewSize.height/2.2
 return collectionViewSize
 }
 }*/

