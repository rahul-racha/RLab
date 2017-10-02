//
//  TableViewController.swift
//  RLab
//
//  Created by rahul rachamalla on 2/22/17.
//  Copyright © 2017 handson. All rights reserved.
//
// From https://forums.estimote.com/t/didenterregion-and-didexitregion-are-not-being-called/2160/15
//0) Let's assume we're starting with the beacon in range of the device.
//1) You call startMonitoring.
//2) Monitoring starts, and the state of the beacon region is determined to be "inside." There should be a call to didDetermineState with this initial state, but there won't be a call to didEnter.
//3) You move out of range of the beacon. As soon as you're out, the clock starts ticking.
//4) When the clocks reaches 30 seconds, the state of the beacon region will change to "outside." There will be a call to didDetermineState. Also, since the state changed from "inside" to "outside," there will be a call to didExit.
//5) Now you move back in range. The state changes to "inside" again. There will be a call to didDetermineState. And again, since the state changed from "outside" to "inside," there now will be a call to didEnter.
//Last but not least, for some devices, and in some special cases, it may actually take up to 15 minutes for iOS to acknowledge the state change. We know this to be the case for iPhone 4S, and I'm not sure about iPads.

import UIKit
import CoreLocation
import Foundation
import Alamofire
//import AlamofireImage
import Charts
import CoreBluetooth

class AvailabilityController: UIViewController,CLLocationManagerDelegate,UITableViewDataSource, UITableViewDelegate,CBPeripheralManagerDelegate,NSURLConnectionDelegate  {


    
    //var refresher: UIRefreshControl!
    var beaconRegion: CLBeaconRegion? //(proximityUUID: NSUUID(uuidString: "")! as UUID, identifier: "handsOnBeacon")
    let locationManager: CLLocationManager = CLLocationManager()
    //var beaconsToMonitor: [CLBeaconRegion] = []
    
    var names = [String]()
    var row_id = 0
    var userName: String?
    var userId: Int?
    var deviceUserId: Int?
    var isDataReceived: Bool = false
    var statusCheck: String = "No"
    var btPeripheralManager: CBPeripheralManager?
    var isBTConnected: Bool = false
    var controller: Bool = true
    var reloadController: Bool?
    var status: Bool?
    var role: String?
    
    @IBOutlet weak var toggleAssistant: UISwitch!
    @IBOutlet var tableView: UITableView!
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        reloadController = false
        //refresher = UIRefreshControl()
        //refresher.attributedTitle = NSAttributedString(string: "refresh")
        //refresher.addTarget(self, action: #selector(AvailabilityController.viewDidLoad), for: UIControlEvents.valueChanged)
        //self.toggleAssistant.isOn = Manager.toggleAssistant
        NotificationCenter.default.addObserver(self, selector: #selector(AvailabilityController.catchStatusNotification(notification:)), name: .statusNotificationKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AvailabilityController.updateAllStatus(_:)), name: .reloadViewKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AvailabilityController.stopAvailability(_:)), name: .stopAvailabilityKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AvailabilityController.stopMonitoringForLogOut(_:)), name: .stopMonitoringKey, object: nil)
        
        toggleAssistant.addTarget(self, action: #selector(AvailabilityController.viewDidLoad), for: UIControlEvents.valueChanged)
        
        //self.tableView.addSubview(refresher)
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
        btPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        self.deviceUserId = Int(Manager.userData?["userid"] as! String)
        if(Manager.userData != nil && Manager.userData!["role"] as! String == "Professor") {
            self.toggleAssistant.isHidden = false
            if(self.toggleAssistant.isOn == true) {
                userId = 6
                self.role = "R.A"
                Manager.toggleAssistant = true
            }else {
                userId = 14
                self.role = "T.A"
                Manager.toggleAssistant = false
            }
        }
        else {
            self.toggleAssistant.isHidden = true
            userId = Int(Manager.userData?["userid"] as! String)
            self.role = Manager.userData?["role"] as! String
        }
        if (Manager.controlLoadAllCells == false) {
        let parameters: Parameters = ["userid": userId! ]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/ChartData.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseJSON { response in
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        Manager.studentDetails = json["student_details"] as? [Dictionary<String,Any>]
                        DispatchQueue.main.async(execute: {
                            self.isDataReceived = true
                            self.tableView.reloadData()
                            if (self.beaconRegion != nil) {
                                self.controller = true
                                self.locationManager.startMonitoring(for: self.beaconRegion!)
                            }
                        })
                        
                    }
                    catch{
                        self.displayAlertMessage(message: "error serializing JSON: \(error)")
                    }
                }
        }
    }
        //self.tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "tableViewCell")
        //self.tableView.register(/*UITableViewCell.self*/TableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        //if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
        self.locationManager.requestAlwaysAuthorization()
        //}
        self.locationManager.delegate = self
        self.beaconRegion?.notifyOnEntry = true;
        self.beaconRegion?.notifyOnExit = true;
        self.beaconRegion?.notifyEntryStateOnDisplay = true;
        
        
        if let installedBeaconUUID = Manager.userData?["beacon_uuid"] as? String {
        if let uuid = UUID(uuidString: installedBeaconUUID) {
            if let maj = Manager.userData?["beacon_major"] as? Int, let min = Manager.userData?["beacon_minor"] as? Int {
                self.beaconRegion = CLBeaconRegion(
                    proximityUUID: uuid,
                    major: CLBeaconMajorValue(maj),
                    minor: CLBeaconMinorValue(min),
                    identifier: "handsOnBeacon")
                print("assigned min and maj")
            } else {
                self.beaconRegion = CLBeaconRegion(
                    proximityUUID: uuid,
                    identifier: "handsOnBeacon")
                print("no min no maj")
            }
        }
        }
        if (self.beaconRegion != nil) {
        self.locationManager.startMonitoring(for: self.beaconRegion!)
        }
        //self.locationManager.requestState(for: self.beaconRegion)
        
        //self.locationManager.startRangingBeacons(in: CLBeaconRegion(proximityUUID: NSUUID(uuidString: "2f234454-cf6d-4a0f-adf2-f4911ba9ffa6")! as UUID, identifier: "handsOnBeacon"))
        
        //self.checkAvailabilityStatus()
        
        
        //        if let uuid = UUID(uuidString: "2f234454-cf6d-4a0f-adf2-f4911ba9ffa6") {
        //        self.beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "handsOnBeacon")
        //            let beaconRegion = CLBeaconRegion(
        //                proximityUUID: uuid,
        //                major: 1,
        //                //minor: 26,
        //                identifier: "iBeacon")
        //beaconRegion.notifyOnEntry = true
        //beaconRegion.notifyOnExit = true
        //beaconRegion.notifyEntryStateOnDisplay = true
        
        //            locationManager.startMonitoring(for: self.beaconRegion)
        //        }
        
        //checkAvailabilityStatus()
        
    }
    

//    @nonobjc func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
//        print("IN AUTHORIZATION FUNC")
//        switch status {
//            
//        case .authorizedAlways:
//            //self.locationManager.startMonitoring(for: self.beaconRegion)
//            //self.locationManager.startRangingBeacons(in: self.beaconRegion)
//            //self.locationManager.requestState(for: self.beaconRegion)
//            print("IN AUTHORIZATION CASE")
//            break
//            
//        case .denied:
//            //let alert = UIAlertController(title: "Warning", message: "You've disabled location update which is required for this app to work. Go to your phone settings and change the permissions.", preferredStyle: UIAlertControllerStyle.alert)
//            //let alertAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.default) { (UIAlertAction) -> Void in }
//            //alert.addAction(alertAction)
//            let warning: String = "You've disabled location update which is required for this app to work. Go to your phone settings and change the permissions."
//            // Display error message if location updates are declined
//            self.displayAlertMessage(message: warning) //self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
//            break
//            
//        default:
//            break
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func refreshView(_ sender: Any) {
        Manager.controlLoadAllCells = false
        viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        //print("I am bak")
        if (self.reloadController == true) {
            //print("I am in ViewAppear")
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var header: String? = nil
        if(Manager.userData != nil && Manager.userData!["role"] as! String == "Professor") {
            if(userId == 6) {
                header = "RA's in Hands-On Lab"
            }else {
                header = "TA's in CS 120/121"
            }
            
        }else {
            if (Manager.userData!["role"] as! String == "R.A") {
                header = "RA's in Hands-On Lab"
            } else {
                header = "TA's in CS 120/121"
            }
        }
        return header
    }
    
    func updateAllStatus(_ notification: Notification) {
        Manager.controlLoadAllCells = false
        viewDidLoad()
    }
    
    func stopMonitoringForLogOut(_ notification: Notification) {
        if (self.beaconRegion != nil) {
            self.locationManager.stopMonitoring(for: self.beaconRegion!)
        }
    }
    
    func stopAvailability(_ notification: Notification) {
        self.controller = true
        let parameters: Parameters = ["userid":self.deviceUserId!,"action":"update","availability":"No"]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/
            .responseString { response in
                //Manager.userPresent = false
                //self.statusCheck = "No"
                //print(response.result.value)
                if let data = response.result.value {
                    print("*******\(data)****")
                    //Manager.userPresent = false
                }
        }
    }
    
    func catchStatusNotification(notification: Notification) {
        let student = notification.userInfo as! [String : Any]
        if (Manager.studentDetails != nil) {
            for i in 0..<Manager.studentDetails!.count {
                if (Manager.studentDetails?[i]["userid"] as? String == student["userid"] as? String) {
                    //UIView.setAnimationsEnabled(false)
                    print(self.role)
                    print(student["role"] as? String)
                    //if (self.role /*Manager.studentDetails?[i]["role"] as? String*/ == student["role"] as? String) {
                    Manager.studentDetails?[i]["status"] = student["status"]
                    let indexPath: IndexPath = IndexPath(row: i, section: 0)
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    //}
                    break
                    
                }
            }
        }
    }
    /*
    func reloadIndexPath(student: [String: Any]) {
        //let _ = self.view
        if (Manager.studentDetails != nil) {
            for i in 0..<Manager.studentDetails!.count {
                if (Manager.studentDetails?[i]["userid"] as? String == student["userid"] as? String) {
                    UIView.setAnimationsEnabled(false)
                    print(self.role)
                    print(student["role"] as? String)
                    //if (self.role /*Manager.studentDetails?[i]["role"] as? String*/ == student["role"] as? String) {
                        Manager.studentDetails?[i]["status"] = student["status"]
                        let indexPath: IndexPath = IndexPath(row: i, section: 0)
                        //self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.bottom)
                    //}
                    break
                    
                }
            }
        }
    }
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if Manager.studentDetails != nil {
            return Manager.studentDetails!.count
        }
        
        return 0
    }
    
   // func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
   // {
   //     return 215;//Choose your custom row height
   // }
    
    func getDayOfWeek(now:String)->Dictionary<String,String> {
        var dateWeekPair = [String : String]()
        
        let week : [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormatter.date(from: now)
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: todayDate!)
        let weekDay = myComponents.weekday! - 1
        let key = dateFormatter.string(from: todayDate!)
        dateWeekPair[key] = week[weekDay]
        return dateWeekPair
    }
    
    func setChart(cell: TableViewCell,dataPoints: [String], values: [Double], indexPath: IndexPath) {
        
        let mapDaysToAbbr: [String: String] = ["Sun":"Su", "Mon":"M", "Tue":"T", "Wed":"W", "Thu":"Th", "Fri":"F", "Sat":"Sa"]
        cell.availabilityChartView.noDataText = "Log Data Not Available"
        //var values: [Double] = [5,7.2,6.1,2,8.5,4.4,7.7,9.1]
        var weekAbbr = [String]()
        let formato:BarChartFormatter = BarChartFormatter()
        let xaxis:XAxis = XAxis()
        
        var dataEntries: [BarChartDataEntry] = [BarChartDataEntry]()
        var xVals = [String]()
        var weekHours: Double = 0
        
        var i = 0
        for data in dataPoints {
            let dataEntry = BarChartDataEntry(x: Double(i) ,y: values[i])
            weekHours = weekHours + values[i]
            dataEntries.append(dataEntry)
            if let day = mapDaysToAbbr[data] {
                weekAbbr.append(day)
                xVals.append(day)
            } else {
                xVals.append("X")
                weekAbbr.append("X")
            }
            _ = formato.stringForValue(Double(i), axis: xaxis)
            i = i+1

        }
        formato.setWeek(receivedWeek: weekAbbr)
        
        xaxis.valueFormatter = formato
        
        cell.weekHours.text = String(round((weekHours-values[values.count-1])*100)/100)
        
        //xaxis.drawGridLinesEnabled = false
        
        // Make sure that only 1 x-label per index is shown
        //xaxis.granularityEnabled = true
        //xaxis.granularity = 0.5
        
        //xaxis.spaceMax = 0.4
        //xaxis.centerAxisLabelsEnabled = true
        //xaxis.labelCount = 8
        //xaxis.setLabelCount(8, force: true) //setLabelsToSkip(0)
        cell.availabilityChartView.xAxis.valueFormatter = xaxis.valueFormatter
        let chartDataSet: BarChartDataSet = BarChartDataSet(values: dataEntries, label: "Hours")
        
        chartDataSet.colors = ChartColorTemplates.pastel()//colorful()

        let chartData = BarChartData()
        chartData.addDataSet(chartDataSet)
        chartData.barWidth = 0.2
        cell.availabilityChartView.data = chartData
        
        //cell.availabilityChartView.drawValueAboveBarEnabled = true
        //cell.availabilityChartView.xAxis.wordWrapEnabled = false
        cell.availabilityChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5, easingOption: .easeInBounce)
        //chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        cell.availabilityChartView.notifyDataSetChanged() // MARK : notifyDataSetCanged() prevents Index out of Range error while assigning chartData to cell data
    
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        // Configure the cell...
        if Manager.studentDetails != nil {
            cell.name.text=Manager.studentDetails?[indexPath.row]["username"] as? String
            cell.projects.text = Manager.studentDetails?[indexPath.row]["projects"] as? String
            /*dispatch_get_global_queue( DispatchQueue.GlobalQueuePriority.default, 0).async(execute: {
                do {
                cell.profileImage.image =  UIImage(data: NSData(contentsOf: NSURL(string:"http://upload.wikimedia.org/wikipedia/en/4/43/Apple_Swift_Logo.png") as! URL) as Data)
                } catch {
                     cell.profileImage.image = #imageLiteral(resourceName: "labimg.jpeg")
                }
            })*/
            cell.profileImage.image = #imageLiteral(resourceName: "labimg.jpeg")
            if (Manager.studentDetails?[indexPath.row]["image"] != nil) {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    let url = URL(string: (Manager.studentDetails?[indexPath.row]["image"] as? String)!)
                    if (url != nil) {
                        let data = try? Data(contentsOf: url!)
                        if (data != nil) {
                            DispatchQueue.main.async{
                                cell.profileImage.image = UIImage(data: data!)
                            }
                        } else {
                            cell.profileImage.image = #imageLiteral(resourceName: "labimg.jpeg")
                        }
                    }  else {
                        cell.profileImage.image = #imageLiteral(resourceName: "labimg.jpeg")
                    }
                }
            }
            
            
            cell.backgroundColor = UIColor.clear
            if Manager.studentDetails?[indexPath.row]["status"] as? String == "Yes" {
                cell.studentActivityStatus(status: StatusColor.available)
                cell.weekHours.textColor = UIColor.blue
            } else {
                cell.studentActivityStatus(status: StatusColor.unknown)
                cell.weekHours.textColor = UIColor.white
            }
            
            cell.availabilityChartView.noDataText = "Availability Info Not Found"
            let xData: [String] = (Manager.studentDetails?[indexPath.row]["xLabels"] as? [String])!
            print(xData)
            let yData: [Double] = (Manager.studentDetails?[indexPath.row]["value"] as? [Double])!
            self.setChart(cell: cell, dataPoints: xData, values: yData, indexPath: indexPath)
        } else {
            cell.name.text = "student" + String(indexPath.row)
            cell.profileImage.image = #imageLiteral(resourceName: "labimg.jpeg")
            
            cell.backgroundColor = UIColor.clear
            cell.studentActivityStatus(status: StatusColor.unknown)
            cell.weekHours.textColor = UIColor.white
            cell.availabilityChartView.noDataText = "Availability Info Not Found"

        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        
        cell.backgroundColor = UIColor.clear
        if Manager.studentDetails?[indexPath.row]["status"] as? String == "Yes" {
            cell.studentActivityStatus(status: StatusColor.available)
            cell.weekHours.textColor = UIColor.blue
            self.status = true
        } else {
            cell.studentActivityStatus(status: StatusColor.selection)
            cell.weekHours.textColor = UIColor.blue
            self.status = false
        }
        self.reloadController = true
        self.userName = Manager.studentDetails?[indexPath.row]["username"] as? String//currentCell.textLabel?.text
        self.userId = Int((Manager.studentDetails?[indexPath.row]["userid"] as? String)!)!
        performSegue(withIdentifier: "LogViewController", sender: self)

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "LogViewController") {
            // initialize new view controller and cast it as your view controller
            let logViewController = segue.destination as! LogViewController
            // your new view controller should have property that will store passed value
            logViewController.userName = self.userName!
            logViewController.userId = self.userId!
            logViewController.status = self.status!
        }
    }
    
    
    // *****************************************************
    /*    func checkAvailabilityStatus() {
     //  Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(AvailabilityController.scheduleChecking), userInfo: nil, repeats: true)
     //print("Inside check avail \(self.statusCheck)")
     }
     
     func scheduleChecking() -> String {
     let userId = Manager.userData!["userid"]!
     //print("Inside schedule checking \(statusCheck)")
     //let parameters: Parameters = ["userid":userId,"action":"update","id":self.row_id]
     let parameters: Parameters = ["userid":userId,"action":"update","availability":statusCheck]
     //        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
     //            .responseString { response in
     //
     //                if let data = response.result.value {
     //                    //print(data)
     //                }
     //        }
     return self.statusCheck
     }
     
     //    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
     //        //print("rangingBeacon:\(region)")
     //        for i in beacons{
     //            //print(i.accuracy)
     //        }
     //    }
     
     */
    
    //  *********************************************************
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    print("Started Monitoring Successfully!")
        print(region)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
        self.controller = true
        self.locationManager.requestState(for: region)
    })
    }
    
    /*
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            if let installedBeaconUUID = Manager.userData?["beacon_uuid"] as? String {
                for tempBeacon in beacons {
                    print(String(describing: tempBeacon.proximityUUID))
                    print(installedBeaconUUID)
                    if (String(describing: tempBeacon.proximityUUID).caseInsensitiveCompare(String(describing:installedBeaconUUID)) == ComparisonResult.orderedSame) {
                        if let uuid = UUID(uuidString: installedBeaconUUID) {
                            if let maj = Manager.userData?["beacon_major"] as? Int, let min = Manager.userData?["beacon_minor"] as? Int {
                                self.beaconRegion = CLBeaconRegion(
                                    proximityUUID: uuid,
                                    major: CLBeaconMajorValue(maj),
                                    minor: CLBeaconMinorValue(min),
                                    identifier: "handsOnBeacon")
                                print("assigned min and maj")
                            } else {
                                self.beaconRegion = CLBeaconRegion(
                                    proximityUUID: uuid,
                                    identifier: "handsOnBeacon")
                                print("no min no maj")
                            }
                            self.controller = true
                            self.locationManager.startMonitoring(for: self.beaconRegion!)
                        }
                    }
                }
            }
        }
    }
    */
    
    func handleInsideRegion() {
        let parameters: Parameters = ["userid":self.deviceUserId!,"action":"insert","availability":"Yes"]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                //self.statusCheck = "Yes"
                //Manager.userPresent = true
                print("Inside Enter reg \(self.statusCheck)")
                if let data = response.result.value {
                    print("*******\(data)****")
                    //Manager.userPresent = true
                    //let id: [String] = data.components(separatedBy: ":")
                    //self.row_id = Int(id[1])!
                }
        }
        
    }
    
    func handleOutsideRegion() {
        let parameters: Parameters = ["userid":self.deviceUserId!,"action":"update","availability":"No"]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/
            .responseString { response in
                //Manager.userPresent = false
                //self.statusCheck = "No"
                //print(response.result.value)
                if let data = response.result.value {
                    print("*******\(data)****")
                    //Manager.userPresent = false
                }
        }
    }
    
    func handleUnknownRegion() {
        let parameters: Parameters = ["userid":self.deviceUserId!,"action":"update","availability":"Yes"]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                //Manager.userPresent = false
                if let data = response.result.value {
                    print("*******\(data)****")
                    //Manager.userPresent = false
                }
                //}
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            print("DID ENTER REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
            print("controlller: \(self.controller)")
            //let userId = Manager.userData!["userid"]!
            // if (Manager.userPresent == false) {
            if (self.controller == false) {
                print("Inside Enter reg \(self.statusCheck)")
                self.handleInsideRegion()
                
            }
        }
    }


    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            print("DID EXIT REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
            print("controlller: \(self.controller)")
            //let userId = Manager.userData!["userid"]!
            //  if (Manager.userPresent == true) {
            //let parameters: Parameters = ["userid":userId,"action":"update","id":self.row_id]
            if (self.controller == false) {
                print("Inside exit reg \(self.statusCheck)")
                self.handleOutsideRegion()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Error monitoring: \(error.localizedDescription)")
        
        //self.statusCheck = "No"
        print("Error location manager \(self.statusCheck)")
        
        //let userId = Manager.userData!["userid"]!
        
        // if (Manager.userPresent == true) {
        //let parameters: Parameters = ["userid":userId,"action":"update","id":self.row_id]
        //if (self.controller == false) {
        self.controller = true
        self.handleUnknownRegion()
        
    }


    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        //let userId = Manager.userData!["userid"]!
        switch state {
            
        case .unknown:
            print("#######I have no memory of this place.")
            self.controller = true
            self.handleUnknownRegion()
            break
            
        case .outside:
            //self.statusCheck = "No"
            print("Inside Det State out \(self.statusCheck)")
            print("controlller: \(self.controller)")
            // if (Manager.userPresent == true) {
            //let parameters: Parameters = ["userid":userId,"action":"update","id":self.row_id]
            if (self.controller == true) {
                self.controller = false
                print("Inside -det sate passed update No")
                self.handleOutsideRegion()
            }
            break
            
        case .inside:
            //self.statusCheck = "Yes"
            print("controlller: \(self.controller)")
            //  if (Manager.userPresent == false) {
            //let parameters: Parameters = ["userid":userId,"action":"update","id":self.row_id]
            if (self.controller == true) {
                self.controller = false
                //Manager.userPresent = true
                print("Inside -det sate passed update Yes")
                self.handleInsideRegion()
                
                print("Inside Det State inside \(self.statusCheck)")
            }
            break
            //default: break
            
        }
        
        //self.locationManager.startMonitoring(for: self.beaconRegion)
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        print("IN BLUETOOTH")
        if #available(iOS 10.0, *) {
            switch peripheral.state {
            case CBManagerState.poweredOn:
                //isBTConnected = true
                //statusCheck = "Yes"
                print("IN BLUETOOTH POWER ON")
                print("controlller: \(self.controller)")
                if (self.beaconRegion != nil) {
                self.locationManager.startMonitoring(for: self.beaconRegion!)
                }
                break
            case CBManagerState.poweredOff:
                //isBTConnected = false
                //statusCheck = "No"
                print("IN BLUETOOTH POWER OFF")
                print("controlller: \(self.controller)")
                //Manager.userPresent = false
                if (self.beaconRegion != nil) {
                self.locationManager.stopMonitoring(for: self.beaconRegion!)
                }
                self.controller = true
                self.handleOutsideRegion()
                break
                /* case CBManagerState.resetting:
                 isBTConnected = false
                 //statusCheck = "No"
                 
                 break
                 case CBManagerState.unauthorized:
                 self.locationManager.requestAlwaysAuthorization()
                 isBTConnected = false
                 //statusCheck = "No"
                 
                 break
                 case CBManagerState.unsupported:
                 displayAlertMessage(message: "Bluetooth Not Supported")
                 isBTConnected = false
                 Manager.userPresent = false
                 //statusCheck = "No"
                 break
                 */
            case CBManagerState.unknown :
                print("BLUETOOTH state unknown")
                //Manager.userPresent = false
                if (self.beaconRegion != nil) {
                self.locationManager.stopMonitoring(for: self.beaconRegion!)
                }
                self.controller = true
                self.handleUnknownRegion()
                break
            default:
                displayAlertMessage(message: "Bluetooth status Unknown")
                isBTConnected = false
                self.controller = true
                //statusCheck = "No"
                if (self.beaconRegion != nil) {
                self.locationManager.stopMonitoring(for: self.beaconRegion!)
                }
                self.handleUnknownRegion()
                break
                
            }
        } else {
            // Fallback on earlier versions
            switch peripheral.state {
            case .poweredOn:
                //isBTConnected = true
                //statusCheck = "Yes"
                print("IN BLUETOOTH POWER ON")
                print("controlller: \(self.controller)")
                if (self.beaconRegion != nil) {
                self.locationManager.startMonitoring(for: self.beaconRegion!)
                }
                break
            case .poweredOff:
                //isBTConnected = false
                //statusCheck = "No"
                print("IN BLUETOOTH POWER OFF")
                print("controlller: \(self.controller)")
                //Manager.userPresent = false
                if (self.beaconRegion != nil) {
                self.locationManager.stopMonitoring(for: self.beaconRegion!)
                }
                self.controller = true
                self.handleOutsideRegion()
                break
                /* case CBManagerState.resetting:
                 isBTConnected = false
                 //statusCheck = "No"
                 
                 break
                 case CBManagerState.unauthorized:
                 self.locationManager.requestAlwaysAuthorization()
                 isBTConnected = false
                 //statusCheck = "No"
                 
                 break
                 case CBManagerState.unsupported:
                 displayAlertMessage(message: "Bluetooth Not Supported")
                 isBTConnected = false
                 Manager.userPresent = false
                 //statusCheck = "No"
                 break
                 */
            case .unknown :
                print("BLUETOOTH state unknown")
                //Manager.userPresent = false
                if (self.beaconRegion != nil) {
                self.locationManager.stopMonitoring(for: self.beaconRegion!)
                }
                self.controller = true
                self.handleUnknownRegion()
                break
            default:
                displayAlertMessage(message: "Bluetooth status Unknown")
                isBTConnected = false
                self.controller = true
                //statusCheck = "No"
                if (self.beaconRegion != nil) {
                self.locationManager.stopMonitoring(for: self.beaconRegion!)
                }
                self.handleUnknownRegion()
                break
                
            }
        }
        //self.locationManager.requestState(for: self.beaconRegion)
        
    }
    
    
    @IBAction func logout(_ sender: Any) {
        //MARK : RequestState and then
        // "action":"update","availability":"Yes" --> when Inside
        // "action":"update","availability":"No" --> when Outside
        Manager.triggerNotifications = false
        if (self.beaconRegion != nil) {
            self.locationManager.stopMonitoring(for: self.beaconRegion!)
        }
        let parameters: Parameters = ["userid":self.deviceUserId!,"action":"update","availability":"No"]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                //Manager.userPresent = false
                if let data = response.result.value {
                    print("*******\(data)****")
                    //Manager.userPresent = false
                }
                //}
                
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.dismiss(animated: true, completion: nil)
        UIApplication.shared.keyWindow?.rootViewController = destinationController
        self.present(destinationController, animated: true, completion: nil)
    }
    

}

extension Notification.Name {
    static let statusNotificationKey = Notification.Name("com.Tlab.status")
    static let reloadViewKey = Notification.Name("com.Tlab.reload")
    static let stopAvailabilityKey = Notification.Name("com.Tlab.stop")
    static let stopMonitoringKey = Notification.Name("com.Tlab.stopMonitoring")
}
