//
//  CustomTabBarController.swift
//  TLab
//
//  Created by rahul rachamalla on 6/1/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadCell(student: [String: Any]) {
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        /*
        let  navController = self.tabBarController?.viewControllers![0] as! UINavigationController
        let availVC = navController.viewControllers[0] as! AvailabilityController
        //let destinationController = storyboard.instantiateViewController(withIdentifier: "AvailabilityController") as! AvailabilityController
        //destinationController.viewDidLoad()
        //UIApplication.shared.keyWindow?.rootViewController = storyboard.instantiateViewController(withIdentifier: "AvailabilityController") as! AvailabilityController
        
        //let destinationController =  UIApplication.shared.keyWindow?.rootViewController as! AvailabilityController
        //destinationController.reloadIndexPath(student: student)
        availVC.reloadIndexPath(student: student)
        Manager.controlLoadAllCells = false
         */
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
