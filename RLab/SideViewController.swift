//
//  SideViewController.swift
//  TLab
//
//  Created by Rahul Racha on 1/27/18.
//  Copyright © 2018 handson. All rights reserved.
//

import UIKit

class SideViewController: UIViewController {
    
//    fileprivate var actionTableViewController: ActionTableViewController!
    let stopMonitoringKey = "com.Tlab.stopMonitoring"
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let actionTVC = self.childViewControllers.first as? ActionTableViewController else {
//            fatalError("Storyboard missing for ActionTableViewController")
//        }
//        actionTableViewController = actionTVC
//        actionTableViewController.delegate = self
    }
    
    @IBAction func logout(_ sender: Any) {
        Manager.triggerNotifications = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: stopMonitoringKey), object: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        UIApplication.shared.keyWindow?.rootViewController = destinationController
        self.dismiss(animated: true, completion: nil)
        self.present(destinationController, animated: true, completion: nil)
    }
    

}
