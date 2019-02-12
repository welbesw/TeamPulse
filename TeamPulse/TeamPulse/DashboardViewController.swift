//
//  DashboardViewController.swift
//  TeamPulse
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(certificateFileNotification(notification:)), name: .newCertificateFile, object: nil)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !MessageManager.sharedInstance.isConnected() {
            if MessageManager.sharedInstance.initialize() {
                MessageManager.sharedInstance.connectToMQTT()
            }
        }
    }
    
    @objc func certificateFileNotification(notification: Notification) {
        DispatchQueue.main.async {
            let fileName = notification.object ?? "[no file name]"
            let alertController = UIAlertController(title: "Loaded File", message: "Loaded your certificate file: \(fileName)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }

}

