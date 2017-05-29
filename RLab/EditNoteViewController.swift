//
//  EditNoteViewController.swift
//  TLab
//
//  Created by rahul rachamalla on 5/8/17.
//  Copyright © 2017 handson. All rights reserved.
//

import UIKit
import Alamofire

class EditNoteViewController: UIViewController, UITextViewDelegate,NSURLConnectionDelegate {


    @IBOutlet var cancelNote: UIBarButtonItem!
    @IBOutlet weak var titleBox: UITextField!
    @IBOutlet weak var descriptionBox: UITextView!
    var noteId: Int?
    var noteTitle: String?
    var noteDescription: String?
    var newNote: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.descriptionBox.delegate = self
        self.descriptionBox.text = "Note"
        self.descriptionBox.textColor = UIColor.lightGray
        self.navigationItem.leftBarButtonItem = nil
        //print(self.newNote)
        //self.navigationItem.leftBarButtonItem = nil
        if (self.newNote != nil && self.newNote == true) {
            //self.titleBox.text = noteTitle!
            //self.descriptionBox.text = noteDescription!
            self.navigationItem.leftBarButtonItem = self.cancelNote
        } else {
            self.navigationItem.leftBarButtonItem = nil
            self.cancelNote = nil
        }
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Note"
            textView.textColor = UIColor.lightGray
        }
    }

    
    @IBAction func saveNote(_ sender: Any) {
        let userId = Int(Manager.userData?["userid"] as! String)
        //print("******")
        //print(self.newNote)
        if (self.titleBox.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == nil || self.descriptionBox.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == nil) {
            self.displayAlertMessage(message: "All fields are required")
            return
        }
        if (self.newNote == true) {
        let parameters: Parameters = ["userid": userId!,"title":self.titleBox!.text!,"description":self.descriptionBox!.text!]
        Alamofire.request("http://qav2.cs.odu.edu/karan/LabBoard/CreateNotes.php",method: .post,parameters: parameters, encoding: URLEncoding.default).validate(statusCode: 200..<300).validate(contentType: ["application/json"])
            .responseJSON { response in
                
                if let _ = response.data {
                    do {
                        DispatchQueue.main.async(execute: {
                            
                            self.dismiss(animated: true, completion: nil)
                        })
                        
                    }
                    //catch{
                        //print("error serializing JSON: \(error)")
                    //}
                }
        }
      }
    }
    
    func displayAlertMessage(message: String) {
        let alertMsg = UIAlertController(title:"Alert", message: message,
                                         preferredStyle:UIAlertControllerStyle.alert);
        
        let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil );
        alertMsg.addAction(confirmAction)
        present(alertMsg, animated:true, completion: nil)
    }

    
    @IBAction func cancelChange(_ sender: Any) {
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let destinationController = storyboard.instantiateViewController(withIdentifier: "NotesViewController") as! NotesViewController
        //self.present(destinationController, animated: true, completion: nil)
        //self.navigationController?.pushViewController(destinationController, animated: true)
        
        self.dismiss(animated: true, completion: nil)
    }
    

}
