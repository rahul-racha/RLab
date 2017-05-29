//
//  TableViewController.swift
//  RLab
//
//  Created by rahul rachamalla on 2/22/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import Alamofire
import Charts

class AvailabilityController11111: UIViewController,CLLocationManagerDelegate,UITableViewDataSource, UITableViewDelegate,/* UISearchResultsUpdating, UISearchBarDelegate,*/ NSURLConnectionDelegate  {
    
    
    //static var tView: UITableView?
    //  @IBOutlet var searchBar: UISearchBar!
    var refresher: UIRefreshControl!
    let locationManager: CLLocationManager = CLLocationManager()
    var beaconsToMonitor: [CLBeaconRegion] = []
    var studentDetails : [Dictionary<String,Any>]?
    var names = [String]()
    var row_id = 0
    var userName: String?
    var userId: Int?
    var flag: Bool = false
    var statusCheck: String = "No"
    
    @IBOutlet var tableView: UITableView!
    //var TA = ["Rahul","Nandith","Girish","Nishant","Abby","Mehak","Monica","Tarek"]
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(AvailabilityController.viewDidLoad), for:UIControlEvents.valueChanged)
        self.tableView.addSubview(refresher)
        let userId = Manager.userData!["userid"]!
        
        let parameters: Parameters = ["userid":userId]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/GetStudentDetails.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseJSON { response in
                
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        self.studentDetails = json["student_details"] as? [Dictionary<String,Any>]
                        DispatchQueue.main.async(execute: {
                            
                            self.tableView.reloadData()
                            self.flag = true
                        })
                        
                    }
                    catch{
                        print("error serializing JSON: \(error)")
                    }
                }
        }
        
        
        // var filteredArray: [String] = []
        // let searchController=UISearchController(searchResultsController:nil)
        
        //  searchController.searchResultsUpdater=self
        //  searchController.dimsBackgroundDuringPresentation=false
        //   definesPresentationContext=true
        //  self.tableView.tableHeaderView=searchController.searchBar
        
        self.locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        if let uuid = UUID(uuidString: "2f234454-cf6d-4a0f-adf2-f4911ba9ffa6"){
            let beaconRegion = CLBeaconRegion(
                proximityUUID: uuid,
                major: 1,
                minor: 26,
                identifier: "iBeacon")
            //beaconRegion.notifyOnEntry = true
            //beaconRegion.notifyOnExit = true
            //beaconRegion.notifyEntryStateOnDisplay = true
            
            locationManager.startMonitoring(for: beaconRegion)
        }
        
        checkAvailabilityStatus()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
        self.tableView.estimatedRowHeight = 150//94
        //self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //status bar inset
        if let tabHeight = self.tabBarController?.tabBar.frame.height{
            self.tableView.contentInset = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: tabHeight, right: 0)
        }else{
            self.tableView.contentInset = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.height, left: 0, bottom: 0, right: 0)
        }
        
        self.tableView.register(UINib.init(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "tableViewCell")
        
        //styleView()
    }
    
    //     func receiveNotification(userID: Int, color: UIColor) {
    //        //let indexPath: IndexPath = [0,userID]
    //        let indexPath = IndexPath(item: userID, section: 0)
    //        Manager.userPresent = "y"
    //        tableView.beginUpdates()
    //        tableView.reloadRows(at: [indexPath], with: .top)
    //        tableView.endUpdates()
    //    }
    
    
    func styleView(){
        let nav = self.navigationController
        nav?.navigationBar.barStyle = .blackTranslucent
        nav?.navigationBar.isTranslucent = true
        nav?.navigationBar.barTintColor = UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1)
        nav?.navigationBar.tintColor = UIColor.magenta
        nav?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        //add buttons
        // self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon-hamburger"), style: .plain, target: self, action: #selector(globeShow))
        // self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    func globeShow(){
        //let vc = MapViewController()
        //        self.tabBarController?.show(vc, sender: self)
        //self.present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    // func filter
    
    //func updateSearchResults(for searchController: UISearchController) {
    //     <#code#>
    
    //}
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        // if searchController.active && searchController.searchBar != "" {
        //    return self.filteredArray.count
        // }else {
        
        
        if self.studentDetails != nil {
            return self.studentDetails!.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 165;//Choose your custom row height
    }
    
    func getDayOfWeek(now:String)->Dictionary<String,String> {
        var dateWeekPair = [String : String]()
        
        let week : [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        print(now)
        let todayDate = dateFormatter.date(from: now)
        print(todayDate)
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        let myComponents = myCalendar.components(.weekday, from: todayDate!)
        let weekDay = myComponents.weekday! - 1
        print("weeekDay: \(todayDate) \(weekDay)")
        let key = dateFormatter.string(from: todayDate!)
        dateWeekPair[key] = week[weekDay]
        return dateWeekPair
    }
    
    func setChart(cell: TableViewCell,dataPoints: [String], values: [Double], day: String, indexPath: IndexPath) {
        //       cell.availabilityChartView.noDataText = "Availability Info Not Logged"
        //let cell1 = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        let formato:BarChartFormatter = BarChartFormatter()
        let xaxis:XAxis = XAxis()
        
        var dataEntries: [BarChartDataEntry] = [BarChartDataEntry]()
        var xVals = [String]()
        //cell.availabilityChartView.xAxis.axisMinimum = 0;
        //cell.availabilityChartView.xAxis.axisMaximum = 8;
        
        
        
        
        var i = 0
        for data in dataPoints/*i in 0..<dataPoints.count*/ {
            print("HEREEEEEEEE \(values[i])")
            let dataEntry = BarChartDataEntry(x: values[i],y: Double(i))
            dataEntries.append(dataEntry)
            xVals.append(data)
            formato.stringForValue(Double(i), axis: xaxis)
            i = i+1
        }
        print("FORMATOO \(formato)")
        xaxis.valueFormatter = formato
        //cell.availabilityChartView.notifyDataSetChanged() // MARK : notifyDataSetCanged() prevents Index out of Range error while assigning chartData to cell data
        cell.availabilityChartView.xAxis.valueFormatter = xaxis.valueFormatter
        let chartDataSet: BarChartDataSet = BarChartDataSet(values: dataEntries, label: "Hours")
        
        //var dataSets : [BarChartDataSet] = [BarChartDataSet]()
        //dataSets.append(chartDataSet)
        let chartData = BarChartData()
        chartData.addDataSet(chartDataSet)
        //chartData.addEntry(<#T##e: ChartDataEntry##ChartDataEntry#>, dataSetIndex: <#T##Int#>)
        
        //let chartData: BarChartData = BarChartData(xVals :xVals, [chartDataSet])//dataSets: dataSets)
        //cell.availabilityChartView.data.barWidth = 0.5
        cell.availabilityChartView.data = chartData
        //chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        
    }
    
    func drawGraph(cell: TableViewCell, daysLog:[Dictionary<String,Any>], indexPath: IndexPath/*, userid: Int*/)
    {
        var mapWeekIndex = ["Sun":1,"Mon":2,"Tue":3,"Wed":4,"Thu":5,"Fri":6,"Sat":7]
        let week: [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        var manHours : [Double] = [0,0,0,0,0,0,0]
        var today: String = "Default"
        let convHour: Double = 60
        
        
        let date = Date()
        print("CURRENT DATE: \(date)")
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd"
        let now = dateformatter.string(from: date)
        print("CURRENT DATE STRING \(now)")
        let todayObject = getDayOfWeek(now: now)
        var day: String = "Default"
        for (key,value) in todayObject {
            today = key
            day = value
        }
        let calendar = Calendar.current
        
        // Replace the hour (time) of both dates with 00:00
        //let date1 = calendar.startOfDayForDate(firstDate)
        //let date2 = calendar.startOfDayForDate(secondDate)
        //let flags = NSCalendar.Unit.day
        var hours: Double = 0
        var minutes: Double = 0
        //Calendar.current.dateComponents([.day], from: today, to: "2017-05-05").day ?? 0
        var diff: Int = 6
        let trackWeek: Int = mapWeekIndex[day]!
        print("day \(day)")
        print("track \(trackWeek)")
        var trackTemp: Int = trackWeek
        let lastDate = dateformatter.date(from: today)!
        print("todays \(lastDate)")
        /*guard*/ let end = calendar.ordinality(of: .day, in: .era, for: lastDate); //else { return 0 }
        //var k = 0
        let logMax = daysLog.count - 1
        for k in 0...logMax {
            //            if(diff != 0 && trackWeek == trackTemp ) {
            //                break
            //            }
            //let components = calendar.components(flags, fromDate: dateTraverse["current_date"], toDate: today, options: [])
            //let first = dateTraverse["current_date"]
            print("value of kkkkkkk \(k)")
            let first = daysLog[k]["current_date"]
            let firstDate = dateformatter.date(from: first as! String)!
            print("list dates: \(firstDate)")
            /*guard*/ let start = calendar.ordinality(of: .day, in: .era, for: firstDate); //else { return 0 }
            print("trav week \(getDayOfWeek(now: first as! String))")
            
            let interval = abs(start! - end!)//components.day  // This will return the number of day(s) between dates
            print("interval \(interval)")
            //            if interval == diff {
            //                manHours[trackTemp] = dateTraverse["hours"] + (dateTraverse["minutes"]/60)
            //                diff++
            //                trackTemp--
            //                if(trackTemp == 0) {
            //                    trackTemp = 7
            //                }
            //            }else {
            //if ((interval <= diff) && (interval >= 0) && diff >= 1) {
            if ((interval <= 6) && (interval >= 0)) {
                trackTemp = trackTemp - interval
                if (trackTemp <= 0) {
                    trackTemp = 7 + trackTemp
                }
                print(trackTemp)
                //print("dateTraverse \(dateTraverse)")
                //print(dateTraverse["hours"] as Any)
                hours = round(Double(/*dateTraverse*/daysLog[k]["hours"] as! Int))
                print("hours \(hours)")
                print("diff \(diff)")
                minutes = 	Double(/*dateTraverse*/daysLog[k]["minutes"] as! Int)/convHour
                print("min \(minutes)")
                print(trackTemp)
                print(round((hours + minutes)*100)/100)
                manHours[trackTemp-1] =  round((hours + minutes)*100)/100
                print("index of manHours \(trackTemp-1)")
                print("array:\(manHours[trackTemp-1])")
                diff = diff - interval
                trackTemp = trackWeek
                
            }
            else {
                break
            }
            
            //   }
        }
        print("manHours \(manHours[0])  \(manHours[1])  \(manHours[2])  \(manHours[3])  \(manHours[4])  \(manHours[5])  \(manHours[6])")
        //manHours = [0,0,0,0,0,0,0]
        var count = 0;
        for data in manHours {
            if(data == 0.0) {
                count += 1
            }
        }
        if count == 7 {
            cell.availabilityChartView.noDataText = "No hours recorded for past 7 days "
        }
        else {
            setChart(cell: cell,dataPoints: week,values :manHours, day: day, indexPath: indexPath)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        // Configure the cell...
        //if self.studentDetails != nil {
        cell.name.text=self.studentDetails?[indexPath.row]["username"] as? String
        cell.lastLocation.text = self.studentDetails?[indexPath.row]["projects"] as? String
        //cell.name.text = (Manager.userData?["username"] as! String)//"Grant Atkins"
        cell.lastLocation.text = "CS120/121 Lab"
        print(" 1 I am here!!!!!!!!!!!!!!!")
        let userId = self.studentDetails?[indexPath.row]["userid"]
        
        
        
        cell.profileImage.image /*af_setImageWithURL*/ = #imageLiteral(resourceName: "labimg.jpeg")//(imageUrl, placeholderImage: nil, filter: nil, imageTransition: .CrossDissolve(0.2))
        //        cell.profileImage.image = (self.studentDetails?[indexPath.row]["mobile_image"] as? String, placeholderImage: nil, filter: nil, imageTransition: .CrossDissolve(0.2))
        
        
        //        cell.profileImage.image = UIImage(named: Manager.userData?["image"] as! String/*"Grant_Atkins"*/)
        //        cell.profileImage.image = UIImage(named: String)
        //print(indexPath)
        //if Manager.userPresent == true {
        //  cell.backgroundColor = UIColor.gray
        //}
        //else {
        cell.backgroundColor = UIColor.clear
        if self.studentDetails?[indexPath.row]["status"] as? String == "Yes" {
            cell.studentActivityStatus(status: StatusColor.available)
        } else {
            cell.studentActivityStatus(status: StatusColor.unknown)
        }
        
        let daysLogStatic: [Dictionary<String,Any>] = [
            [
                "current_date": "2017-04-04",
                "hours": 5,
                "minutes": 22
            ],
            [
                "current_date": "2017-04-03",
                "hours": 6,
                "minutes": 0
            ],
            [
                "current_date": "2017-04-02",
                "hours": 6,
                "minutes": 0
            ],
            [
                "current_date": "2017-04-01",
                "hours": 2,
                "minutes": 20
            ],
            [
                "current_date": "2017-03-31",
                "hours": 3,
                "minutes": 40
            ],
            [
                "current_date": "2017-03-29",
                "hours": 7,
                "minutes": 10
            ],
            [
                "current_date": "2017-03-28",
                "hours": 5,
                "minutes": 50
            ],
            [
                "current_date": "2017-03-27",
                "hours": 5,
                "minutes": 4
            ],
            [
                "current_date": "2017-03-23",
                "hours": 0,
                "minutes": 0
            ],
            [
                "current_date": "2017-03-22",
                "hours": 0,
                "minutes": 0
            ]
            
        ]
        
        // }
        // if searchController.active && searchController.searchBar != "" {
        //    cell.name.text = self.filteredArray[indexPath.row]
        //  }else {
        
        // }
        
        let parameters: Parameters = ["userid" : userId as Any]
        if (self.studentDetails != nil && flag == true) {
            Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/GetAvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"]).responseJSON { response in
                if let data = response.data {
                    var daysLog: [Dictionary <String,Any>]?
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        daysLog = json["total_time"] as? [Dictionary<String,Any>]
                        print("day log in cell \(daysLog)")
                        
                        DispatchQueue.main.async(execute: {
                            //self.tableView.reloadData()
                            self.drawGraph(cell: cell,daysLog: daysLogStatic/*!*/,indexPath: indexPath/*,userid: userId!*/)
                        })
                    }
                    catch{
                        cell.availabilityChartView.noDataText = "Availability Data Couldn't Be Loaded"
                        print("error serializing JSON: \(error)")
                    }
                }
            }
        }
        // }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("You selected cell: \(indexPath.row)!")
        
        // Get Cell Label
        //let indexPath = tableView.indexPathForSelectedRow!
        //let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        
        self.userName = self.studentDetails?[indexPath.row]["username"] as? String//currentCell.textLabel?.text
        print("in available: \(userName)")
        self.userId = Int((self.studentDetails?[indexPath.row]["userid"] as? String)!)!
        print("in available: \(userId)")
        
        performSegue(withIdentifier: "LogViewController", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "LogViewController") {
            // initialize new view controller and cast it as your view controller
            let logViewController = segue.destination as! LogViewController
            // your new view controller should have property that will store passed value
            logViewController.userName = self.userName!
            print("while passing in available: \(userName)")
            logViewController.userId = self.userId!
            print("while passing in available: \(userId)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            print("DID ENTER REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
            print(Manager.userData!)
            
            let userId = Manager.userData!["userid"]!
            
            
            
            let parameters: Parameters = ["userid":userId,"action":"insert","availability":"Yes"]
            Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
                .responseString { response in
                    self.statusCheck = "Yes"
                    
                    if let data = response.result.value {
                        print(data)
                        print("Inside Enter reg \(self.statusCheck)")
                        let id: [String] = data.components(separatedBy: ":")
                        self.row_id = Int(id[1])!
                    }
            }
        }
        
        //let indexPath: IndexPath = [0,0]
        
        // Manager.userPresent = true
        //            let v = DotView();
        //            v.styleFrame(b: UIColor.green)
        //  tableView.beginUpdates()
        //  tableView.reloadRows(at: [indexPath], with: .top)
        // tableView.endUpdates()
        
        //let indexPath = IndexPath(item: rowNumber, section: 0)
        
        
        //let cell = /*self.tableView*/TableViewController.tView?.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        //cell.backgroundColor = UIColor.green
        
        
        //self.tableView.beginUpdates()
        //self.tableView.endUpdates()
        
        /*if TableViewController.tView != nil {
         TableViewController.tView?.beginUpdates();
         TableViewController.tView?.endUpdates()
         //self.tableView.endUpdates()
         }*/
        
        //var someInts: [Int] = [0,0]
        //tableView(<#T##tableView: UITableView##UITableView#>, someInts)
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            print("DID EXIT REGION: uuid: \(beaconRegion.proximityUUID.uuidString)")
            print(Manager.userData!)
            
            
            print(Manager.userData!)
            
            let userId = Manager.userData!["userid"]!
            
            //let parameters: Parameters = ["userid":userId,"action":"update","id":self.row_id]
            let parameters: Parameters = ["userid":userId,"action":"update","availability":"No"]
            Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
                .responseString { response in
                    self.statusCheck = "No"
                    print("Inside exit reg \(self.statusCheck)")
                    if let data = response.result.value {
                        print(data)
                    }
            }
            
            
            
            
            //            Manager.userPresent = false
            //            Manager.userPresent = true
            //            let v = DotView();
            //            v.styleFrame(b: UIColor.red)
            // let indexPath: IndexPath = [0,0]
            // tableView.beginUpdates()
            //  tableView.reloadRows(at: [indexPath], with: .top)
            //  tableView.endUpdates()
            
            
            
            
            //let cell = /*self.tableView*/TableViewController.tView?.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
            //cell.backgroundColor = UIColor.red
            //self.tableView.beginUpdates()
            //self.tableView.endUpdates()
            /*if TableViewController.tView != nil {
             TableViewController.tView?.beginUpdates();
             TableViewController.tView?.endUpdates()
             //self.tableView.endUpdates()
             }*/
            
        }
    }
    
    func checkAvailabilityStatus() {
        Timer.scheduledTimer(timeInterval: 600.0, target: self, selector: #selector(AvailabilityController.scheduleChecking), userInfo: nil, repeats: true)
        print("Inside check avail \(self.statusCheck)")
    }
    
    func scheduleChecking() -> String {
        let userId = Manager.userData!["userid"]!
        print("Inside schedule checking \(statusCheck)")
        //let parameters: Parameters = ["userid":userId,"action":"update","id":self.row_id]
        let parameters: Parameters = ["userid":userId,"action":"update","availability":statusCheck]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseString { response in
                
                if let data = response.result.value {
                    print(data)
                }
        }
        return self.statusCheck
    }
    
    //    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    //        print("rangingBeacon:\(region)")
    //        for i in beacons{
    //            print(i.accuracy)
    //        }
    //    }
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started Monitoring Successfully!")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        switch state {
            
        case .unknown:
            print("I have no memory of this place.")
            
        case .inside:
            var text = "All aboard the hype train."
            self.statusCheck = "Yes"
            let userId = Manager.userData!["userid"]!
            
            //let parameters: Parameters = ["userid":userId,"action":"update","id":self.row_id]
            let parameters: Parameters = ["userid":userId,"action":"update","availability":"Yes"]
            Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
                .responseString { response in
                    
                    print("Inside -det sate passed update Yes")
                    if let data = response.result.value {
                        print(data)
                    }
            }
            print("Inside Det State inside \(self.statusCheck)")
            
            //if (enteredRegion) {
            text = "Welcome to Millennium Phalcon kiddo."
            //}
            
            // Notifications.display(text)
            
        case .outside:
            var text = "Sthaaaaap."
            self.statusCheck = "No"
            print("Inside Det State out \(self.statusCheck)")
            
            let userId = Manager.userData!["userid"]!
            
            //let parameters: Parameters = ["userid":userId,"action":"update","id":self.row_id]
            let parameters: Parameters = ["userid":userId,"action":"update","availability":"No"]
            Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
                .responseString { response in
                    
                    print("Inside -det sate passed update No")
                    if let data = response.result.value {
                        print(data)
                    }
            }
            // if (!enteredRegion) {
            text = "I find your lack of faith, distrubing!"
            //}
            
            //Notifications.display(text)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Error monitoring: \(error.localizedDescription)")
        //   Manager.userPresent = false
        
        //        let v = DotView();
        //        v.styleFrame(b: UIColor.gray)
        //  let indexPath: IndexPath = [0,0]
        //  tableView.beginUpdates()
        //   tableView.reloadRows(at: [indexPath], with: .top)
        //  tableView.endUpdates()
        //let cell = /*self.tableView*/TableViewController.tView?.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        //cell.backgroundColor = UIColor.red
        //self.tableView.beginUpdates()
        //self.tableView.endUpdates()
        /*if TableViewController.tView != nil {
         TableViewController.tView?.beginUpdates();
         TableViewController.tView?.endUpdates()
         //self.tableView.endUpdates()
         }*/
        
    }
    
}
