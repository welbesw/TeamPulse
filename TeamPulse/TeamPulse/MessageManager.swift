//
//  MessageManager.swift
//  TeamPulse
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation
import AWSIoT

class MessageManager {
    
    static let sharedInstance = MessageManager()
    
    var iotDataManager: AWSIoTDataManager!
    
    var heartRatesDict = [String : HeartRateModel]()
    
    func initialize() -> Bool {
        
        let endpointId = ConfigManager.awsEndpointId()
        guard endpointId.count > 0 else {
            return false
        }
        
        let iotEndPoint = AWSEndpoint(urlString:"https://\(endpointId).iot.us-east-1.amazonaws.com")
        let iotDataConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, endpoint: iotEndPoint, credentialsProvider: nil)
        
        let dataManagerKey = "AWSIoTDataManager"
        
        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: dataManagerKey)
        iotDataManager = AWSIoTDataManager(forKey: dataManagerKey)
        return true
    }
    
    private func mqttEventCallback(_ status: AWSIoTMQTTStatus ) {
        print("connection status = \(connectionStatusString())")
        if status == .connected {
            subscribeToHeartRates()
        }
    }
    
    func connectToMQTT() {
        
        getCertificateId(completionHandler: { (certificateId) in
            if let certificateId = certificateId {
                self.iotDataManager.connect(withClientId: ConfigManager.userId() ?? "",
                                            cleanSession: true,
                                            certificateId: certificateId,
                                            statusCallback: self.mqttEventCallback)
            }
        })
    }
    
    func isConnected() -> Bool {
        guard iotDataManager != nil else {
            return false
        }
        let connectionStatus = iotDataManager.getConnectionStatus()
        return connectionStatus == .connected || connectionStatus == .connecting
    }
    
    func connectionStatusString() -> String {
        switch(iotDataManager.getConnectionStatus()) {
        case .unknown:
            return "Unknown"
        case .connecting:
            return "Connecting"
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        case .connectionRefused:
            return "Connection Refused"
        case .connectionError:
            return "Connection Error"
        case .protocolError:
            return "Connection Protocol Error"
        }
    }
    
    func publishHeartRate(heartRate: Double, userName: String, userId: String) {
        let heartRateString = String(format: "%.0f", heartRate)
        let json = """
        {
        "heartRate": \(heartRateString),
        "userName": "\(userName)",
        "userId": "\(userId)"
        }
        """
        let success = iotDataManager.publishString(json, onTopic: "heartrate", qoS: .messageDeliveryAttemptedAtMostOnce)
        print("Published message: \(success)")
    }
    
    func subscribeToHeartRates() {
        iotDataManager.subscribe(toTopic: "heartrate", qoS: .messageDeliveryAttemptedAtLeastOnce, messageCallback: { (data) in
            //Parse the message looking for JSON format data
            do {
                let heartRateModel = try JSONDecoder().decode(HeartRateModel.self, from: data)
                print(heartRateModel)
                self.heartRatesDict[heartRateModel.userId] = heartRateModel
                NotificationCenter.default.post(name: .newHeartRateMQTT, object: heartRateModel)
            } catch {
                print("Error decoding message.")
            }
        }) {
            //ack callback
            print("subscribed to heartrate topic")
        }
    }
    
    private func getCertificateId(completionHandler: @escaping ((String?) -> Void)) {
        
        //If we have a certificate id, use it
        if let certificateId = ConfigManager.loadedCertificateId() {
            completionHandler(certificateId)
            return
        }
        
        //Check to see if we have certificate file loaded
        guard let certificateFileName = ConfigManager.certificateFileName() else {
            print("Certificate file not yet loaded.  Load a file via Files App")
            completionHandler(nil)
            return
        }
        
        //Attempt to load the PKCS12 file from the file in documents
        //Assumes files does not have a passphrase
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            completionHandler(nil)
            return
        }
        
        let p12FileUrl = documentsURL.appendingPathComponent(certificateFileName)

        guard let data = try? Data(contentsOf: p12FileUrl) else {
            completionHandler(nil)
            return
        }
        
        if AWSIoTManager.importIdentity( fromPKCS12Data: data, passPhrase:"", certificateId:p12FileUrl.absoluteString) {
            // Set the certificate ID and ARN values to indicate that we have imported
            // our identity from the PKCS12 file
            ConfigManager.setLoadedCertificateId(certificateId: p12FileUrl.absoluteString)
            completionHandler(p12FileUrl.absoluteString)
        } else {
            completionHandler(nil)
        }
    }
}

