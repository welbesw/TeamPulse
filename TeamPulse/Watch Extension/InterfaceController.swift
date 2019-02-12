//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var heartRateLabel: WKInterfaceLabel!
    @IBOutlet var startStopButton: WKInterfaceButton!
    
    var workoutSession: HKWorkoutSession?
    var watchSession = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        heartRateLabel.setText("--")
        
        monitorHeartRate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
            watchSession.delegate = self
            watchSession.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func didTapStartStopWorkout() {
        
        if(workoutSession == nil) {
            startWorkout()
        } else {
            stopWorkout()
        }
    }
    
    func stopWorkout() {
        workoutSession?.stopActivity(with: Date())
        workoutSession?.end()
        workoutSession = nil
        
        startStopButton.setTitle("Start Workout")
    }
    
    func startWorkout() {
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .walking
        workoutConfiguration.locationType = .indoor
        
        do {
            if workoutSession == nil {
                workoutSession = try HKWorkoutSession(healthStore: HealthDataManager.sharedInstance.healthStore!, configuration: workoutConfiguration)
                workoutSession?.startActivity(with: Date())
                
                startStopButton.setTitle("Stop Workout")
            }
        } catch {
            print("Error starting workout session: \(error.localizedDescription)")
        }
    }
    
    func monitorHeartRate() {
        HealthDataManager.sharedInstance.observeHeartRateSamples { (heartRate) -> (Void) in
            print("heart rate sample: \(heartRate)")
            self.heartRateLabel.setText(String(format: "%.0f", heartRate))
            self.sendHeartRate(heartRate: heartRate)
        }
    }
    
    func sendHeartRate(heartRate: Double) {
        if watchSession.isReachable {
            watchSession.sendMessage(["heartRate" : heartRate], replyHandler: nil) { (error) in
                print("Error sending heart rate message: \(error.localizedDescription)")
            }
        } else {
            print("iPhone session is not reachable")
        }
    }
}

extension InterfaceController: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
}
