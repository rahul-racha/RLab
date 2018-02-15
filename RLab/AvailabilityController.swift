//
//  TableViewController.swift
//  RLab
//
//  Created by rahul rachamalla on 2/22/17.
//  Copyright © 2017 handson. All rights reserved.
//
// iBeacon reference https://forums.estimote.com/t/didenterregion-and-didexitregion-are-not-being-called/2160/15

import UIKit
import CoreLocation
import Foundation
import Alamofire
import Charts
import CoreBluetooth

class AvailabilityController: UIViewController,CLLocationManagerDelegate,UITableViewDataSource, UITableViewDelegate,CBPeripheralManagerDelegate,NSURLConnectionDelegate  {
    
    var beaconRegion: CLBeaconRegion?
    let locationManager: CLLocationManager = CLLocationManager()
    var names = [String]()
    var row_id = 0
    var userName: String?
    var userId: Int?
    var deviceUserId: Int?
    var beaconMap: [String: String] = [:]
    var btPeripheralManager: CBPeripheralManager?
    var controller: Bool = true
    var reloadController: Bool = false
    //var status: Bool?
    var role: String?
    var location: String = "out"
    var color: UIColor?
    var preLocation: String = "out"
    
    @IBOutlet weak var toggleAssistant: UISwitch!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var menuBtnItem: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = String(describing: Manager.userData?["first_name"] as! String)
        let attrs = [
            NSForegroundColorAttributeName: UIColor.blue,
            NSFontAttributeName: UIFont(name: "Avenir-Black", size: 20)!
        ]
        UINavigationBar.appearance().titleTextAttributes = attrs
        self.menuBtnItem.target = revealViewController()
        self.menuBtnItem.action = #selector(SWRevealViewController.revealToggle(_:))
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        toggleAssistant.addTarget(self, action: #selector(AvailabilityController.viewDidLoad), for: UIControlEvents.valueChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(AvailabilityController.catchStatusNotification(notification:)), name: .statusNotificationKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AvailabilityController.updateAllStatus(_:)), name: .reloadViewKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AvailabilityController.stopAvailability(_:)), name: .stopAvailabilityKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AvailabilityController.stopMonitoringForLogOut(_:)), name: .stopMonitoringKey, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AvailabilityController.pingWebService(_:)), name: .pingLogKey, object: nil)
        
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.distanceFilter = 5000
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
        btPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        
        if (Manager.userData == nil) {
            return
        }
        var proxyUser = 0
        print(Manager.userData)
        self.deviceUserId = Int(Manager.userData?["userid"] as! String)
        self.role = Manager.userData?["role"] as! String
        
        if (self.role == "Professor") {
            self.toggleAssistant.isHidden = false
            if (self.toggleAssistant.isOn == true) {
                proxyUser = 6
                //self.role = "R.A"
                Manager.toggleAssistant = true
            }else {
                proxyUser = 3
                //self.role = "T.A"
                Manager.toggleAssistant = false
            }
        }
        else {
            self.toggleAssistant.isHidden = true
            proxyUser = Int(Manager.userData?["userid"] as! String)!
        }
        
        if (self.role == "T.A" || self.role == "student") {
            self.tableView.allowsSelection = false
        }
        //if (Manager.controlLoadAllCells == false) {
        let parameters: Parameters = ["userid": proxyUser ]
        Alamofire.request(Manager.chartDataService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseData { response in
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        Manager.studentDetails = json["student_details"] as? [Dictionary<String,Any>]
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                        
                    }
                    catch {
                        self.displayAlertMessage(message: "error serializing JSON: \(error)")
                    }
                }
        }
        //}
       
            Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(self.reloadAvailView), userInfo: nil, repeats: true)

        
    }
    
    /*func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
     if (status == .authorizedAlways){
     if (CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)){
     if(CLLocationManager.isRangingAvailable()){
     self.startScanning()
     }
     }
     }
     }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }
    
    @IBAction func refreshView(_ sender: Any) {
        //Manager.controlLoadAllCells = false
        self.viewDidLoad()
    }
    
    func reloadAvailView() {
        if (Manager.isAppActive == true) {
            self.viewDidLoad()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.reloadController == true) {
            self.viewDidLoad()
            //self.tableView.reloadData()
        } else {
            self.reloadController = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func updateAllStatus(_ notification: Notification) {
        //Manager.controlLoadAllCells = false
        print("in reload view fn")
        if (Manager.isAppActive == true) {
            viewDidLoad()
        }
    }
    
    
    func stopMonitoringForLogOut(_ notification: Notification) {
        if (self.beaconRegion != nil) {
            self.locationManager.stopMonitoring(for: self.beaconRegion!)
            self.locationManager.stopRangingBeacons(in: self.beaconRegion!)
            self.locationManager.stopUpdatingLocation()
        }
        self.handleOutsideRegion()
        
    }
    
    func pingWebService(_ notification: Notification) {
        if (Manager.triggerNotifications == true) {
            let parameters: Parameters = ["user_id":self.deviceUserId!, "user_status": "Yes"]
            Alamofire.request(Manager.pingServerService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/
                .responseString { response in
                    if let data = response.result.value {
                        print("*******\(data)****")
                    }
            }
        }
    }
    
    func stopAvailability(_ notification: Notification) {
        self.controller = true
        let parameters: Parameters = ["userid":self.deviceUserId!,"action":"update","availability":"No", "location":"outside"]
        Alamofire.request(Manager.availabilityLogService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/
            .responseString { response in
                if let data = response.result.value {
                    self.location = "outside"
                    print("*******\(data)****")
                }
        }
    }
    
    func catchStatusNotification(notification: Notification) {
        if (Manager.isAppActive == true) {
            let student = notification.userInfo as! [String : Any]
            if (Manager.studentDetails != nil) {
                for i in 0..<Manager.studentDetails!.count {
                    if (Manager.studentDetails?[i]["userid"] as? String == student["userid"] as? String) {
                        Manager.studentDetails?[i]["status"] = student["status"]
                        Manager.studentDetails?[i]["location"] = student["location"]
                        let indexPath: IndexPath = IndexPath(row: i, section: 0)
                        self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                        break
                        
                    }
                }
            }
        }
    }
    
    
    func mapBeacons() {
        for beaconInfo in Manager.beaconDetails! {
            let key = beaconInfo["beacon_minor"] as! String
            self.beaconMap[key] = beaconInfo["lab"] as? String
        }
    }
    
    
    func startScanning() {
        if (self.role != "student" && self.role != "Professor") {
            self.mapBeacons()
            if let identifier = Manager.beaconDetails?[0]["beacon_uuid"] as? String {
                let uuid = UUID(uuidString: identifier)!
                self.beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "handsOnBeacon")
                print("#####")
                print(self.beaconRegion)
                print(uuid)
                print("#####")
                self.locationManager.startUpdatingLocation()
                locationManager.startRangingBeacons(in: beaconRegion!)
            }
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started Monitoring Successfully!")
        print(region)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.controller = true
            self.locationManager.requestState(for: region)
        })
    }
    
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Number of Beacons founds:",beacons.count)
        var min: NSNumber = -1
        var maj: NSNumber = -1
        var loc: String = "empty"
        print(self.beaconMap)
        if beacons.count > 0 {
            print(region.proximityUUID)
            //let uuid = UUID(uuidString: (region.u)) //self.beaconRegion?
            for b in beacons {
                if (b.major == 1) {
                    let minorKey = String(describing:b.minor)
                    if let temp = self.beaconMap[minorKey] {
                        loc = temp
                    } else {
                        loc = "outside"
                    }
                    min = b.minor
                    maj = b.major
                } else {
                    loc = "outside"
                }
                
                if (loc != "outside" && region.proximityUUID != nil) {
                    self.beaconRegion = CLBeaconRegion(
                        proximityUUID: region.proximityUUID,
                        major: CLBeaconMajorValue(maj),
                        minor: CLBeaconMinorValue(min),
                        identifier: "handsOnBeacon")
                    self.beaconRegion?.notifyOnEntry = true;
                    self.beaconRegion?.notifyOnExit = true;
                    self.beaconRegion?.notifyEntryStateOnDisplay = true;
                } else {
                    self.handleOutsideRegion()
                }
                print("PRINTING REGION")
                print(self.beaconRegion)
                print("loc:\(loc)")
                print("pre:\(self.preLocation)")
                print("location:\(self.location)")
                self.preLocation = loc
                if (loc != self.location) {
                    if (loc == "outside") {
                        self.handleOutsideRegion()
                    } else {
                        print("I AM MONOTORING NOW")
                        locationManager.startMonitoring(for: self.beaconRegion!)
                    }
                } else {
                    
                }
                
                break
            }
        } else {
            if ("outside" != self.location) {
                self.handleOutsideRegion()
            }
        }
    }
    
    func handleInsideRegion() {
        if (self.preLocation != "out" && self.role != "student" && self.role != "Professor") {
            let parameters: Parameters = ["userid":self.deviceUserId!,"action":"insert","availability":"Yes", "location": self.preLocation]
            Alamofire.request(Manager.availabilityLogService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
                .responseString { response in
                    print("Inside Enter reg inside")
                    if let data = response.result.value {
                        self.location = self.preLocation
                        print("*******\(data)****")
                    }
            }
        }
        
    }
    
    func handleOutsideRegion() {
        //if (self.preLocation != "out") {
        if (self.role != "student" && self.role != "Professor") {
            let parameters: Parameters = ["userid":self.deviceUserId!,"action":"update","availability":"No", "location": "outside"]
            Alamofire.request(Manager.availabilityLogService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)/*.validate(contentType: ["application/json"])*/
                .responseString { response in
                    if let data = response.result.value {
                        self.location = "outside"
                        print("*******\(data)****")
                    }
            }
        }
    }
    
    func handleUnknownRegion() {
        print("UNKNOWN REGION")
        //if (self.preLocation != "out") {
        if (self.role != "student" && self.role != "Professor") {
            let parameters: Parameters = ["userid":self.deviceUserId!,"action":"update","availability":"No", "location": "outside"]
            Alamofire.request(Manager.availabilityLogService,method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
                .responseString { response in
                    if let data = response.result.value {
                        self.location = "outside"
                        print("*******\(data)****")
                    }
                    
            }
        }
    }
    
    /*func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
     if let beaconRegion = region as? CLBeaconRegion {
     print("DID ENTER REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
     print("controller: \(self.controller)")
     if (self.controller == false) {
     print("Inside Enter reg yes")
     self.handleInsideRegion()
     
     }
     }
     }
     
     
     func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
     if let beaconRegion = region as? CLBeaconRegion {
     print("DID EXIT REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
     print("controlller: \(self.controller)")
     if (self.controller == false) {
     print("Inside exit reg out")
     self.handleOutsideRegion()
     }
     }
     }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Error monitoring: \(error.localizedDescription)")
        self.controller = true
        self.handleUnknownRegion()
    }*/
    
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("minor")
        print(region.value(forKey: "minor"))
        print("major")
        print(region.value(forKey: "major"))
        print("OKay in diddetemine")
        print(CLRegion.self)
        switch state {
        case .unknown:
            print("#######I have no memory of this place.")
            self.controller = true
            self.handleUnknownRegion()
            break
            
        case .outside:
            print("Inside Det State out")
            print("controlller: \(self.controller)")
            if (self.controller == true) {
                self.controller = false
                print("Inside -det sate passed update No")
                self.handleOutsideRegion()
            }
            break
            
        case .inside:
            print("Inside Det State IN")
            if (self.controller == true) {
                self.controller = false
                print("Inside -det sate passed update Yes")
                self.handleInsideRegion()
            }
            break
            
        }
        
    }
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        print("IN BLUETOOTH")
        if #available(iOS 10.0, *) {
            switch peripheral.state {
            case CBManagerState.poweredOn:
                print("IN BLUETOOTH POWER ON")
                print("controlller: \(self.controller)")
                self.startScanning()
                break
            case CBManagerState.poweredOff:
                print("IN BLUETOOTH POWER OFF")
                print("controlller: \(self.controller)")
                if (self.beaconRegion != nil) {
                    self.locationManager.stopMonitoring(for: self.beaconRegion!)
                    self.locationManager.stopRangingBeacons(in: self.beaconRegion!)
                    self.locationManager.stopUpdatingLocation()
                }
                //self.controller = true
                self.handleOutsideRegion()
                break
            default:
                displayAlertMessage(message: "Bluetooth status Unknown")
                if (self.beaconRegion != nil) {
                    self.locationManager.stopMonitoring(for: self.beaconRegion!)
                    self.locationManager.stopRangingBeacons(in: self.beaconRegion!)
                    self.locationManager.stopUpdatingLocation()
                }
                //self.controller = true
                self.handleUnknownRegion()
                break
                
            }
        } else {
            // Fallback on earlier versions
            switch peripheral.state {
            case .poweredOn:
                print("IN BLUETOOTH POWER ON")
                print("controlller: \(self.controller)")
                self.startScanning()
                break
            case .poweredOff:
                print("IN BLUETOOTH POWER OFF")
                print("controlller: \(self.controller)")
                if (self.beaconRegion != nil) {
                    self.locationManager.stopMonitoring(for: self.beaconRegion!)
                    self.locationManager.stopRangingBeacons(in: self.beaconRegion!)
                    self.locationManager.stopUpdatingLocation()
                }
                //self.controller = true
                self.handleOutsideRegion()
                break
            default:
                displayAlertMessage(message: "Bluetooth status Unknown")
                if (self.beaconRegion != nil) {
                    self.locationManager.stopMonitoring(for: self.beaconRegion!)
                    self.locationManager.stopRangingBeacons(in: self.beaconRegion!)
                    self.locationManager.stopUpdatingLocation()
                }
                //self.controller = true
                self.handleUnknownRegion()
                break
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var header: String? = nil
        if (self.toggleAssistant.isOn == true) {
            header = "RA's in Hands-On Lab"
        } else {
            header = "TA's in CS 120/121"
        }
        return header
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if Manager.studentDetails != nil {
            return Manager.studentDetails!.count
        }
        
        return 0
    }
    
    //     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    //     {
    //         return UITableViewAutomaticDimension;//Choose your custom row height 215
    //     }
    
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
        if (self.role == "T.A" || self.role == "student") {
            cell.weekHours.isHidden = true
        }
        // Configure the cell...
        if Manager.studentDetails != nil {
            cell.name.text = Manager.studentDetails?[indexPath.row]["username"] as? String
            cell.projects.text = Manager.studentDetails?[indexPath.row]["projects"] as? String
            cell.profileImage.image = #imageLiteral(resourceName: "default")
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
                            cell.profileImage.image = #imageLiteral(resourceName: "default")
                        }
                    }  else {
                        cell.profileImage.image = #imageLiteral(resourceName: "default")
                    }
                }
            }
            
            
            cell.backgroundColor = UIColor.clear
            cell.location.text = ""
            if (Manager.studentDetails?[indexPath.row]["status"] as? String == "Yes") {
                let tempLoc = Manager.studentDetails?[indexPath.row]["location"] as! String
                if (tempLoc == "ta_office" || tempLoc == "ra_office") {
                    cell.studentActivityStatus(status: StatusColor.available)
                    if (tempLoc == "ta_office") {
                        cell.location.text = "1103B(Dragas)"
                    } else {
                        cell.location.text = "1101(Dragas)"
                    }
                } else if (Manager.studentDetails?[indexPath.row]["location"] as? String == "recitation") {
                    cell.studentActivityStatus(status: StatusColor.recitation)
                    cell.location.text = "in recitation"
                }
                cell.weekHours.textColor = UIColor.blue
            } else {
                cell.studentActivityStatus(status: StatusColor.unknown)
                cell.weekHours.textColor = UIColor.white
            }
            if (self.role == "T.A" || self.role == "student") {
                cell.availabilityChartView.isHidden = true
            } else {
                cell.availabilityChartView.isHidden = false
            }
            cell.availabilityChartView.noDataText = "Availability Info Not Found"
            let xData: [String] = (Manager.studentDetails?[indexPath.row]["xLabels"] as? [String])!
            print(xData)
            let yData: [Double] = (Manager.studentDetails?[indexPath.row]["value"] as? [Double])!
            self.setChart(cell: cell, dataPoints: xData, values: yData, indexPath: indexPath)
        } else {
            cell.name.text = "student" + String(indexPath.row)
            cell.profileImage.image = #imageLiteral(resourceName: "default")
            
            cell.backgroundColor = UIColor.clear
            cell.studentActivityStatus(status: StatusColor.unknown)
            cell.weekHours.textColor = UIColor.white
            cell.availabilityChartView.noDataText = "Availability Info Not Found"
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        cell.backgroundColor = UIColor.clear
        self.color = UIColor.gray
        if Manager.studentDetails?[indexPath.row]["status"] as? String == "Yes" {
            let tempLoc = Manager.studentDetails?[indexPath.row]["location"] as? String
            if ( tempLoc == "ta_office" || tempLoc == "ra_office") {
                cell.studentActivityStatus(status: StatusColor.available)
                self.color = UIColor.green
            } else if (Manager.studentDetails?[indexPath.row]["location"] as? String == "recitation") {
                cell.studentActivityStatus(status: StatusColor.recitation)
                self.color = UIColor.orange
            }
            
            cell.weekHours.textColor = UIColor.blue
            //self.status = true
        } else {
            cell.studentActivityStatus(status: StatusColor.unknown)
            cell.weekHours.textColor = UIColor.white
            //self.status = false
        }
        //self.reloadController = false
        self.userName = Manager.studentDetails?[indexPath.row]["username"] as? String
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
            //logViewController.status = self.status!
            logViewController.color = self.color!
        }
    }
    
}

extension Notification.Name {
    static let statusNotificationKey = Notification.Name("com.Tlab.status")
    static let reloadViewKey = Notification.Name("com.Tlab.reload")
    static let stopAvailabilityKey = Notification.Name("com.Tlab.stop")
    static let stopMonitoringKey = Notification.Name("com.Tlab.stopMonitoring")
    static let pingLogKey = Notification.Name("com.Tlab.ping")
    //static let terminationKey = Notification.Name("com.Tlab.termination")
}
