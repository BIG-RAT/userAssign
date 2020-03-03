//
//  ViewController.swift
//  userAssign
//
//  Created by Leslie Helou on 11/1/19.
//  Copyright © 2019 Leslie Helou. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDelegate {
    
    @IBOutlet var main_UIView: UIView!
    
    // variables for API call
    var baseUrl    = ""
    var username   = ""
    var password   = ""
    var deviceUdid = ""
        
    @IBOutlet weak var name_TextField: UITextField!
    @IBOutlet weak var message_TextView: UITextView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBAction func name_TextFieldFunction(_ sender: Any) {
        submit_Button(self)
    }
    
    
    @IBAction func submit_Button(_ sender: Any) {
        // clear message field
        self.message_TextView.text = ""
        spinner.startAnimating()
        // xml for updating device
        let assignXml = """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <mobile_device>
            <location>
                <username>\(String(describing: name_TextField.text!))</username>
                <realname/>
                <real_name/>
                <email_address/>
                <position/>
                <phone/>
                <phone_number/>
                <department/>
                <building/>
                <room/>
            </location>
        </mobile_device>
        """
        let deviceUrl   = "\(baseUrl)/JSSResource/mobiledevices/udid/\(deviceUdid)"
        let creds       = "\(username):\(password)"
        let base64Creds = creds.data(using: .utf8)?.base64EncodedString()
        // attempt to update - start
        URLCache.shared.removeAllCachedResponses()
        
        let encodedUrl = NSURL(string: deviceUrl)
        let request = NSMutableURLRequest(url: encodedUrl! as URL)
        request.httpMethod = "PUT"
        request.httpBody = assignXml.data(using: String.Encoding.utf8)
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(String(describing: base64Creds!))", "Content-type" : "application/xml"]
        
        let session = Foundation.URLSession(configuration: configuration, delegate: self as? URLSessionDelegate, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            if let httpResponse = response as? HTTPURLResponse {
                print("status code: \(httpResponse.statusCode)")
//                print("\(httpResponse.description)")
                if httpResponse.statusCode >= 199 && httpResponse.statusCode <= 299 {
                    self.message_TextView.text = "successfully assigned"
                    self.message_TextView.textColor = UIColor.green
                    self.message_TextView.font =  UIFont(name: "HelveticaNeue", size: CGFloat(32))
                } else {
                    self.message_TextView.text = "failed to assigned"
                    self.message_TextView.textColor = UIColor.red
                    self.message_TextView.font =  UIFont(name: "HelveticaNeue", size: CGFloat(32))
                }
            }
            self.spinner.stopAnimating()
        })
        task.resume()
        // attempt to update - end
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // HexColor - Mac App Store
        // https://www.hackingwithswift.com/example-code/uicolor
        main_UIView.backgroundColor = UIColor(red: 0x5C/255.0, green: 0x78/255.0, blue: 0x94/255.0, alpha: 1.0)
        
        // ensure we have an app config
        if let configDict = UserDefaults.standard.dictionary(forKey: "com.apple.configuration.managed"),
            let _ = configDict["baseUrl"],
            let _ = configDict["username"],
            let _ = configDict["password"],
            let _ = configDict["udid"] {
            baseUrl    = configDict["baseUrl"] as! String
            username   = configDict["username"] as! String
            password   = configDict["password"] as! String
            deviceUdid = configDict["udid"] as! String
            // app config is valid
        } else {
            // handle missing app config here
            self.message_TextView.text = "Missing App Config"
            self.message_TextView.textColor = UIColor.red
            self.message_TextView.font =  UIFont(name: "HelveticaNeue", size: CGFloat(32))
            // for testing without app config
            baseUrl    = "https://your.jamf.server"
            username   = "userAssign"
            password   = "S3cr3t"
            deviceUdid = "c49c160637321fa3905c4311ad0d2313d93015bb"   // test device
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping(  URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

