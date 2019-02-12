//
//  SessionHandler.swift
//  TeamPulse
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation
import WatchConnectivity

class SessionHandler: NSObject, WCSessionDelegate {
    
    static let sharedInstance = SessionHandler()
    
    private var session = WCSession.default
    
    override init() {
        super.init()
        
        if isWatchSessionSupported() {
            session.delegate = self
            session.activate()
        }
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
    }
    
    func isWatchSessionSupported() -> Bool {
        return WCSession.isSupported()
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
        
        //Reactivate the session
        self.session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let heartRate = message["heartRate"] as? Double {
            print("heart rate from message: \(heartRate)")
            NotificationCenter.default.post(name: .newHeartRate, object: heartRate)
            //MessageManager.sharedInstance.publishHeartRate(heartRate: heartRate, user: "will")
        }
    }
}
