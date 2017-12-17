//
//  NotesViewController.swift
//  TLab
//
//  Created by rahul rachamalla on 5/7/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

class NotesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSURLConnectionDelegate {

    
    @IBOutlet var notesCollectionView: UICollectionView!
    @IBOutlet weak var toggleAssistant: UISwitch!
    
    let stopMonitoringKey = "com.Tlab.stopMonitoring"
    //var refresher: UIRefreshControl!
    var userId: Int?
    var subrole: String?
    var studentNotes : [Dictionary<String,Any>]?
    var noteId: Int?
    var noteTitle: String?
    var noteDescription: String?
    var newNote: Bool?
    var reload: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        print("i am first")
        self.newNote = false
        // self.toggleAssistant.isOn = Manager.toggleAssistant
        /*refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(NotesViewController.viewDidLoad), for: UIControlEvents.valueChanged)
        self.notesCollectionView.addSubview(refresher)*/
        
        toggleAssistant.addTarget(self, action: #selector(NotesViewController.viewDidLoad), for: UIControlEvents.valueChanged)
        if(Manager.userData != nil && Manager.userData!["role"] as! String == "Professor") {
            self.toggleAssistant.isHidden = false
            if(self.toggleAssistant.isOn == true) {
                userId = 6
                self.subrole = "R.A"
                Manager.toggleAssistant = true
            }else {
                userId = 14
                self.subrole = "T.A"
                Manager.toggleAssistant = false
            }
        }
        else {
            self.toggleAssistant.isHidden = true
            self.subrole = Manager.userData?["role"] as? String
            userId = Int(Manager.userData?["userid"] as! String)
        }
        
        //userId = Int(Manager.userData?["userid"] as! String)
        let parameters: Parameters = ["userid": userId == nil ? 0:userId! ]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/GetNotes.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseJSON { response in
                if let data = response.data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                        self.studentNotes = json["notes_data"] as? [Dictionary<String,Any>]
                        DispatchQueue.main.async(execute: {
                            self.notesCollectionView.reloadData()
                        })
                        
                    }
                    catch{
                        //print("error serializing JSON: \(error)")
                        self.studentNotes = nil
                        self.notesCollectionView.reloadData()
                    }
                }
                
        }
        
            self.reload = false
        
    }
    
    @IBAction func refreshView(_ sender: Any) {
        self.reload = true
        viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("I am bak")
        print(reload)
        if (reload == true) {
        self.viewDidLoad()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   /* func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }*/
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if self.studentNotes == nil {
            return 0
        } else {
            return self.studentNotes!.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotesCollectionViewCell", for: indexPath) as! NotesCollectionViewCell
  
        cell.layoutIfNeeded()
        cell.layer.cornerRadius = 8.0
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.masksToBounds = true
        
        if (self.studentNotes != nil) {
            cell.id = Int((self.studentNotes?[indexPath.row]["id"] as? String)!)
            cell.cellTitle.text = (self.studentNotes?[indexPath.row]["title"] as? String)!
            cell.descriptionNote.text = (self.studentNotes?[indexPath.row]["description"] as? String)!
            cell.delNote?.layer.setValue(indexPath.row, forKey: "cellIndex")
            cell.delNote?.layer.setValue(cell.id, forKey: "cellId")
        }
        
        return cell
    }

    @IBAction func deleteNote(_ sender: Any) {
        let idVal : Int = ((sender as AnyObject).layer.value(forKey: "cellId")) as! Int
        print("id \(idVal)")
        //self.studentNotes.remove(at: i)
        let parameters: Parameters = ["id": idVal]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/DeleteNotes.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseJSON { response in
                
                if response.data != nil {
                    //                    do {
                    //let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                    //self.studentNotes = json["notes_data"] as? [Dictionary<String,Any>]
                    DispatchQueue.main.async(execute: {
                        if (self.studentNotes != nil) {
                            for i in 0..<(self.studentNotes?.count)! {
                                let id = Int((self.studentNotes?[i]["id"] as? String)!)!
                                if (id == idVal) {
                                    self.studentNotes?.remove(at: i)
                                    break
                                }
                            }
                        self.viewDidLoad()
                        }
                        
                    })
                    
                    //                    }
                    //                    catch{
                    //print("error serializing JSON: \(error)")
                    //                    }
                }
        }
        
        //self.notesCollectionView.reloadData()
    }


  /*  MARK: Code for Editing Notes
    @nonobjc func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) {
        
        self.noteId = Int((self.studentNotes?[indexPath.row]["id"] as? String)!)
        self.noteTitle = (self.studentNotes?[indexPath.row]["title"] as? String)!
        print("--------")
        print(self.noteId as Any)
        print(self.noteTitle as Any)
        print("--------")
        //print("in available: \(userId)")
        self.noteDescription = (self.studentNotes?[indexPath.row]["description"] as? String)!
        self.newNote = false
        self.performSegue(withIdentifier: "EditNoteViewController", sender: nil)
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let destinationController = storyboard.instantiateViewController(withIdentifier: "EditNoteViewController") as! EditNoteViewController
//        destinationController.newNote = self.newNote
//        destinationController.noteId = self.noteId
//        destinationController.noteTitle = self.noteTitle
//        destinationController.noteDescription = self.noteDescription
//        self.present(destinationController, animated: true, completion: nil)
    
    }
    
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //if (segue.identifier == "EditNoteViewController") {
            // initialize new view controller and cast it as your view controller

            let EditNoteViewController = segue.destination as! EditNoteViewController
            // your new view controller should have property that will store passed value
            if (self.newNote != true) {
            EditNoteViewController.noteId =  self.noteId!
            EditNoteViewController.noteTitle = self.noteTitle!
            EditNoteViewController.noteDescription = self.noteDescription!
            }
            EditNoteViewController.newNote = self.newNote
        //}
    }
*/

    @IBAction func createNote(_ sender: Any) {
        self.newNote = true
        self.reload = true
        //performSegue(withIdentifier: "EditNoteViewController", sender: self)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationController = storyboard.instantiateViewController(withIdentifier: "EditNoteViewController") as! EditNoteViewController
        destinationController.newNote = self.newNote
        destinationController.subrole = self.subrole
        self.present(destinationController, animated: true, completion: nil)
    }
    
    
    @IBAction func logout(_ sender: Any) {
        Manager.triggerNotifications = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: stopMonitoringKey), object: nil)
        
        /*let parameters: Parameters = ["userid": Manager.userData!["userid"]!,"action":"update","availability":"No"]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/AvailabilityLog.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300)
            .responseString { response in
                Manager.userPresent = false
                if let data = response.result.value {
                    print("*******\(data)****")
                    
                }
                
        }*/
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let destinationController = storyboard.instantiateViewController(withIdentifier: "ViewController")
    UIApplication.shared.keyWindow?.rootViewController = destinationController
    self.dismiss(animated: true, completion: nil)
    self.present(destinationController, animated: true, completion: nil)

    }
}
