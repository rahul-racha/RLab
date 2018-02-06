//
//  AppDelegate.swift
//  RLab
//
//  Created by rahul rachamalla on 1/24/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var backgroundTask: UIBackgroundTaskIdentifier?
    let statusNotificationKey = "com.Tlab.status"
    let reloadViewKey = "com.Tlab.reload"
    let pingLogKey = "com.Tlab.ping"
    let stopAvailabilityKey = "com.Tlab.stop"
    let stopMonitoringKey = "com.Tlab.stopMonitoring"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications(application: application)
        Manager.studentDetails = nil
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        UIApplication.shared.keyWindow?.rootViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        return true
    }
    
    func registerForPushNotifications(application: UIApplication) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in }
            application.registerForRemoteNotifications()
        } else if #available(iOS 9.0, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        } else if #available(iOS 8.0, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("I am resign active")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: stopAvailabilityKey), object: nil)
        
        print("entered background")
        //Manager.isBackground = true
        //Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleBackground), userInfo: nil, repeats: true)
    }
    
    /*func handleBackground() {
     print("in handle back")
     if (Manager.isBackground == true) {
     print("in handle if true")
     extendBackgroundTime()
     }
     }*/
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //Manager.isBackground = false
        
        print("IN foreground")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //Manager.isBackground = false
        print("became active")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: reloadViewKey), object: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: stopMonitoringKey), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: stopAvailabilityKey), object: nil)
        print("app terminate")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("$$$$$$")
        print(deviceTokenString)
        print("$$$$$$")
        Manager.deviceId = deviceTokenString
        //print(isDevelopmentEnvironment())
    }
    
    /*func isDevelopmentEnvironment() -> Bool {
     guard let filePath = Bundle.main.path(forResource: "embedded", ofType:"mobileprovision") else {
     return false
     }
     do {
     let url = URL(fileURLWithPath: filePath)
     let data = try Data(contentsOf: url)
     guard let string = String(data: data, encoding: .ascii) else {
     return false
     }
     if string.contains("<key>aps-environment</key>\n\t\t<string>development</string>") {
     return true
     }
     } catch {}
     return false
     }*/
    
    //func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UNNotificationSettings) {
    
    //}
    
    /*func extendBackgroundTime() {
     if (self.backgroundTask != nil && self.backgroundTask! != UIBackgroundTaskInvalid) {
     return
     }
     print("Attempting to extend background running time")
     let self_terminate = true
     self.backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "extend_ranging", expirationHandler: {
     print("Background task expired by iOS");
     if (self_terminate) {
     UIApplication.shared.endBackgroundTask(self.backgroundTask!)
     self.backgroundTask = UIBackgroundTaskInvalid
     }
     }
     )
     print("I am in extend")
     var _  = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.remainingTime), userInfo: nil, repeats: true)
     }*/
    
    /*func remainingTime() {
     print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
     }*/
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        let data  = userInfo["aps"] as! [String : Any]
        if (data["pingDevice"] as? String == "pinged") {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: pingLogKey), object: nil)
            completionHandler(UIBackgroundFetchResult.newData);
        } else {
            if let reloadView = data["reloadView"] as? String {
                if (reloadView == "Yes") {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: reloadViewKey), object: nil)
                } else {
                    if (data["data"] as? [String : Any] != nil) {
                        let student: [String: Any] = data["data"] as! [String : Any]
                        if (student["userid"] != nil && student["status"] != nil) {
                            //if (Manager.triggerNotifications == true) {
                            //updateCell(student: student)
                            //Manager.controlLoadAllCells = true
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: statusNotificationKey), object: nil, userInfo: student)
                            //Manager.controlLoadAllCells = false
                            //}
                            
                        }
                        completionHandler(UIBackgroundFetchResult.newData);
                    } else {
                        completionHandler(UIBackgroundFetchResult.noData);
                    }
                }
                if #available(iOS 10.0, *) {
                    let content = UNMutableNotificationContent()
                    content.badge = 10
                } else {
                    // Fallback on earlier versions
                }
                
            } else {
                completionHandler(UIBackgroundFetchResult.noData);
            }
        }
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("i am not available in simulator \(error)")
        
    }
    
}

