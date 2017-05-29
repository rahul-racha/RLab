//
//  sample.swift
//  RLab
//
//  Created by rahul rachamalla on 1/29/17.
//  Copyright © 2017 handson. All rights reserved.
//

import Foundation
/*
 let loginString = String(format: "%@:%@", username, password)
 let loginData = loginString.data(using: String.Encoding.utf8)!
 let base64LoginString = loginData.base64EncodedString()
 
 let url = URL(string: "http://qav2.cs.odu.edu/karan/LabBoard/login.php")!
 var request = URLRequest(url: url)
 request.httpMethod = "GET"
 request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
 
 // fire off the request
 // make sure your class conforms to NSURLConnectionDelegate
 let urlConnection = NSURLConnection(request: request, delegate: self)!
 
 print(urlConnection)
 */

/*      dispatch_async(dispatch_get_main_queue(), { () -> Void in
 let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Login") as! UIViewController
 self.presentViewController(viewController, animated: true, completion: nil)
 })
 */
/*
let urlpath = "http://qav2.cs.odu.edu/karan/LabBoard/login.php"
let url:NSURL = NSURL(string: urlpath)!
let session = URLSession.shared

let request = NSMutableURLRequest(url: url as URL)
request.httpMethod = "POST"

let parameters = "username=saikaran&password=123"
request.httpBody = parameters.data(using: String.Encoding.utf16)

let task = session.dataTask(with: request as URLRequest) {
    (
    data,response,error) in
    guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
        
        print("error")
        return
    }
    if let dataString = NSString(data:data!, encoding: String.Encoding.utf16.rawValue) {
        print(dataString)
    }
}
task.resume()
print(task)
 */

//////////////////////////////////////////////////
/*    switch response.result {
 case .success:
 let JSON = response.result.value
 //JSON = JSON as! NSDictionary
 print("JSON: \(JSON)")
 break
 case .failure: break
 }*/
/////////////////////////////////////////////////


/////////////////////
/*
 var request = URLRequest(url: URL(string: "http://qav2.cs.odu.edu/karan/LabBoard/login.php")!)
 request.httpMethod = "POST"
 let postString = "username="+username+"&password="+password
 request.httpBody = postString.data(using: .utf8)
 let task = URLSession.shared.dataTask(with: request) { data, response, error in
 guard let data = data, error == nil else {                                                 // check for fundamental networking error
 self.displayAlertMessage(message: "Network Error=\(error)") //print("error=\(error)")
 return
 }
 
 if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
 print("statusCode should be 200, but is \(httpStatus.statusCode)")
 print("response = \(response)")
 }
 
 //let responseString = String(data: data, encoding: .utf8)
 //print("responseString = \(responseString)")
 //respStr = responseString
 //print("BOOO \(respStr ?? "haii")")
 rawData = data
 }
 task.resume()
 */
///////////////////////
     
