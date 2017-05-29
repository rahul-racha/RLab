//
//  DataManager.swift
//  RLab
//
//  Created by rahul rachamalla on 2/22/17.
//  Copyright © 2017 handson. All rights reserved.
//

import Foundation

struct Manager {
    
    static var userData: [String: Any]?
    static var userPresent: Bool? = nil
    static var deviceId: String?
    static var controlData: Bool?  // Need to put this in CreateAgileViewController
    static var toggleAssistant: Bool = false
    static var triggerNotifications: Bool = false
}


/*
func displayAlertMessage(message: String) {
    let alertMsg = UIAlertController(title:"Alert", message: message,
                                     preferredStyle:UIAlertControllerStyle.alert);
    
    let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
    alertMsg.addAction(confirmAction)
    present(alertMsg, animated:true, completion: nil)
}
 */
