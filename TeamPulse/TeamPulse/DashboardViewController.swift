//
//  DashboardViewController.swift
//  TeamPulse
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(certificateFileNotification(notification:)), name: .newCertificateFile, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(newHeartRateMQTT(notification:)), name: .newHeartRateMQTT, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !MessageManager.sharedInstance.isConnected() {
            if MessageManager.sharedInstance.initialize() {
                MessageManager.sharedInstance.connectToMQTT()
            }
        }
    }
    
    @objc func newHeartRateMQTT(notification: Notification) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MessageManager.sharedInstance.heartRatesDict.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let keys = MessageManager.sharedInstance.heartRatesDict.keys.sorted()
        let key = keys[indexPath.row]
        let heartRateModel = MessageManager.sharedInstance.heartRatesDict[key]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "heartRateCell", for: indexPath) as! HeartRateCollectionViewCell
        
        if let heartRateModel = heartRateModel {
            cell.heartRateLabel.text = String(heartRateModel.heartRate)
            cell.userNameLabel.text = heartRateModel.userName
        } else {
            cell.heartRateLabel.text = "--"
            cell.userNameLabel.text = "unassigned"
        }
        
        return cell
    }

}

