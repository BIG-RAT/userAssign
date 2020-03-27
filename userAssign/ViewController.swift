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
    var baseUrl       = ""
    var username      = ""
    var password      = ""
    var deviceUdid    = ""
    var eaShow        = false
    var eaID          = "0"
    var eaName        = ""
    var popup_choices = [String]()
    var customConfig  = ""
        
    @IBOutlet weak var name_TextField: UITextField!
    @IBOutlet weak var assetTag_TextField: UITextField!
    @IBOutlet weak var config_Button: UIButton!
    @IBOutlet weak var selectedConfig_TextField: UITextField!
    
    
    @IBOutlet weak var message_TextView: UITextView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBAction func name_TextFieldFunction(_ sender: Any) {
        submit_Button(self)
    }
    
    @IBAction func selectConfig_Action(_ sender: Any) {
        performSegue(withIdentifier: "configSegue", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let configVC: ConfigViewController = segue.destination as! ConfigViewController
        configVC.configArray = popup_choices
    }
    
    @IBAction func submit_Button(_ sender: Any) {
        var general             = ""
        var location            = ""
        var extension_attribute = ""
        
        // clear message field
        self.message_TextView.text = ""
        spinner.startAnimating()
        
        if assetTag_TextField.text != "" {
            general = """
            <general>
                <asset_tag>\(String(describing: assetTag_TextField.text!))</asset_tag>
            </general>
            """
        }
        
        if selectedConfig_TextField.text != "" {
            extension_attribute = """
            <extension_attributes>
              <extension_attribute>
                <id>18</id>
                <name>\(String(describing: eaName))</name>
                <type>String</type>
                <multi_value>false</multi_value>
                <value>\(String(describing: selectedConfig_TextField.text!))</value>
              </extension_attribute>
            </extension_attributes>
            """
        }
        
        location = """
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
        """
        
        // xml for updating device
        let assignXml = """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <mobile_device>
            \(String(describing: general))
            \(String(describing: location))
            \(String(describing: extension_attribute))
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
        
        let session = Foundation.URLSession(configuration: configuration, delegate: self as URLSessionDelegate, delegateQueue: OperationQueue.main)
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
            }   // if let httpResponse - end
            self.spinner.stopAnimating()
        })
        task.resume()
        // attempt to update - end
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        print("[viewWillAppear]")
//        selectedConfig_TextField.text = "\(Preferences.selectedConfig)"
//    }

    
    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
        // HexColor - Mac App Store
        // https://www.hackingwithswift.com/example-code/uicolor
        main_UIView.backgroundColor = UIColor(red: 0x5C/255.0, green: 0x78/255.0, blue: 0x94/255.0, alpha: 1.0)
        selectedConfig_TextField.textAlignment = .center
        
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
            if let _ = configDict["eaShow"], let _ = configDict["eaID"] {
                eaShow = configDict["eaShow"] as! Bool
                eaID   = configDict["eaID"] as! String
                if eaShow {
                    config_Button.isHidden = false
                    selectedConfig_TextField.isHidden = false
                }
            }
        } else {
            // handle missing app config here
            self.message_TextView.text = "Missing App Config"
            self.message_TextView.textColor = UIColor.red
            self.message_TextView.font =  UIFont(name: "HelveticaNeue", size: CGFloat(32))
            // for simulator testing without app config
            baseUrl    = "https://m.hickoryhillseast.net"
            username   = "testUserAssign"
            password   = "S3cr3t"
            deviceUdid = "80023a617b92bbc7aca27463a3df5ac0b188a654"   // test device udid
            eaShow     = true
            eaID       = "18"
            if eaShow {
                config_Button.isHidden = false
                selectedConfig_TextField.isHidden = false
            }
        }   // if let configDict - end
        
        // pull list for dropdown from EA
                let attributeURL = "\(baseUrl)/JSSResource/mobiledeviceextensionattributes/id/\(eaID)"
                let creds        = "\(username):\(password)"
                let base64Creds  = creds.data(using: .utf8)?.base64EncodedString()
                // attempt to update - start
                URLCache.shared.removeAllCachedResponses()
                
                let encodedUrl = NSURL(string: attributeURL)
                let request = NSMutableURLRequest(url: encodedUrl! as URL)
                request.httpMethod = "GET"
//                request.httpBody = assignXml.data(using: String.Encoding.utf8)
                let configuration = URLSessionConfiguration.default
                configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(String(describing: base64Creds!))", "Accept" : "application/json"]
                
                let session = Foundation.URLSession(configuration: configuration, delegate: self as URLSessionDelegate, delegateQueue: OperationQueue.main)
                let task = session.dataTask(with: request as URLRequest, completionHandler: {
                    (data, response, error) -> Void in
                    if let httpResponse = response as? HTTPURLResponse {
//                        print("httpResponse: \(httpResponse)")
                        do {
                            let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                            if let dataJSON = json as? [String:Any] {
                                print("dataJSON: \(dataJSON)")
                                let eaAttributes = dataJSON["mobile_device_extension_attribute"] as! [String:Any]
                                self.eaName = eaAttributes["name"] as! String
                                
                                self.config_Button.setTitle("\(self.eaName): ", for: .normal)
                                
                                guard let _ = eaAttributes["input_type"] else { return }
                                let input_type = eaAttributes["input_type"] as! [String:Any]
                                if input_type["type"] as! String == "Pop-up Menu" {
                                    self.popup_choices = input_type["popup_choices"] as! [String]
                                    print("popup_choices for \(self.eaName): \(self.popup_choices)")
                                }
                            }
                        }
                    }   // if let httpResponse - end
                    self.spinner.stopAnimating()
                })
                task.resume()
                // attempt to update - end
        
        
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping(  URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}

