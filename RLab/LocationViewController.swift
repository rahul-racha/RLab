//
//  LocationViewController.swift
//  RLab
//
//  File created by rahul rachamalla on 2/15/17.
//  Reused the code created by Grant Atkins
//  on 9/28/16.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController,CLLocationManagerDelegate /*,NSObject*/ {

    @IBOutlet weak var b1Val: UILabel!
    @IBOutlet weak var b2Val: UILabel!
    @IBOutlet weak var b3Val: UILabel!
    @IBOutlet weak var b4Val: UILabel!
    
    @IBOutlet weak var closestBeaconVal: UILabel!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways){
            if (CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self)){
                if(CLLocationManager.isRangingAvailable()){
                    self.startScanning()
                }
            }
        }
    }
    
    func startScanning(){
        let uuid = UUID(uuidString: "2f234454-cf6d-4a0f-adf2-f4911ba9ffa6")!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: "myBeaons")
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print("Number of Beacons founds:",beacons.count)
        if beacons.count > 0 {
            
            var flag = false
            for b in beacons{
                print("Approximate Accuray for Beacon \(b.major) \(b.minor) = ",b.accuracy)
                updateLabels(minor: Int(b.minor), accuracy: Float(b.accuracy))
                
                //order is in closest to farthest beacon, unknown = -1.0
                if b.proximity != .unknown && !flag{
                    flag = true
                    updateDistance(b.proximity)
                    DispatchQueue.main.async {
                        self.closestBeaconVal.text = "\(b.minor)"
                    }
                    
                }
            }
            
        } else {
            updateDistance(.unknown)
        }
    }
    
    func updateDistance(_ distance: CLProximity) {
        UIView.animate(withDuration: 0.8) {
            switch distance {
            case .unknown:
                self.view.backgroundColor = UIColor.gray
                print("unkkw")
            case .far:
                self.view.backgroundColor = UIColor.blue
                
            case .near:
                self.view.backgroundColor = UIColor.orange
                
            case .immediate:
                self.view.backgroundColor = UIColor.red
            }
        }
    }
    
    func updateLabels(minor: Int,accuracy: Float){
        switch(minor){
        case 1:
            DispatchQueue.main.async {
                self.b1Val.text = "\(accuracy)"
            }
        case 2:
            DispatchQueue.main.async {
                self.b2Val.text = "\(accuracy)"
            }
        case 3:
            DispatchQueue.main.async {
                self.b3Val.text = "\(accuracy)"
            }
        case 4:
            DispatchQueue.main.async {
                self.b4Val.text = "\(accuracy)"
            }
        default:
            break
        }
    }
}
