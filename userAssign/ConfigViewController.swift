//
//  ConfigViewController.swift
//  userAssign
//
//  Created by Leslie Helou on 3/27/20.
//  Copyright © 2020 Leslie Helou. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var configs_TableView: UITableView!
    
    var configArray  = [String]()
    var selectConfig = ""
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectConfig = configArray[indexPath.row]
        Preferences.selectedConfig = configArray[indexPath.row]
//        print("[didSelectRowAt] "+configArray[indexPath.row])
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return configArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customConfig", for: indexPath)
        cell.textLabel?.text = configArray[indexPath.row]
        return cell
    }
    
    @IBAction func cancel_Action(_ sender: Any) {
        Preferences.selectedConfig = ""
        dismiss(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let vc = presentingViewController as? ViewController {
            DispatchQueue.main.async {
                vc.selectedConfig_TextField.text = "\(Preferences.selectedConfig)"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}
