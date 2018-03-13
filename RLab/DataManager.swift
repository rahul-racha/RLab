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
    static var beaconDetails: [[String: Any]]?
    static var sectionDetails: [String: String]?
    static var extras: [String: Any]?
    static var deviceId: String?
    static var controlData: Bool?  // Need to put this in CreateAgileViewController
    static var toggleAssistant: Bool = false
    static var triggerNotifications: Bool = false
    static var studentDetails : [Dictionary<String,Any>]?
    static var isAppActive: Bool = false
    //static var isBackground: Bool = false
    
    //web services
    static var registerUserService = "http://qav2.cs.odu.edu/karan/LabBoard/registerUser.php"
    static var loginService = "http://qav2.cs.odu.edu/karan/LabBoard/loginNew.php"
    static var chartDataService = "http://qav2.cs.odu.edu/karan/LabBoard/ChartData.php"
    static var pingServerService = "http://qav2.cs.odu.edu/karan/LabBoard/pingServer.php"
    static var availabilityLogService = "http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLogNew.php"
    static var getAvailabilityLogService = "http://qav2.cs.odu.edu/karan/LabBoard/GetAvailabilityLog.php"
    static var agileBoardService = "http://qav2.cs.odu.edu/karan/LabBoard/GetAgileBoardData.php"
    static var getAgileUpdateService = "http://qav2.cs.odu.edu/karan/LabBoard/GetUpdateLog.php"
    static var updateAgileMsgService = "http://qav2.cs.odu.edu/karan/LabBoard/newUpdate.php"
    static var createAgileService = "http://qav2.cs.odu.edu/karan/LabBoard/CreateAgileBoardData.php"
    static var getNotesService = "http://qav2.cs.odu.edu/karan/LabBoard/GetNotes.php"
    static var createNotesService = "http://qav2.cs.odu.edu/karan/LabBoard/CreateNotes.php"
    static var delNotesService = "http://qav2.cs.odu.edu/karan/LabBoard/DeleteNotes.php"
    static var addAsstService = "http://qav2.cs.odu.edu/karan/LabBoard/AddAssistant.php"
    static var getUserDetailsService = "http://qav2.cs.odu.edu/karan/LabBoard/getUserDetails.php"
    
    static var updateProfileService = "http://qav2.cs.odu.edu/karan/LabBoard/EditProfile.php"
    static var configUserService = "http://qav2.cs.odu.edu/karan/LabBoard/ConfigUsers.php"
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
