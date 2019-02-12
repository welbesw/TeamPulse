//
//  AppDelegate.swift
//  TeamPulse
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //If there's not already a user id GUID assigned, store one
        if ConfigManager.userId() == nil {
            ConfigManager.setUserId(userId: UUID().uuidString)
        }
        
        let _ = HealthDataManager.sharedInstance.initialize()
        
        if SessionHandler.sharedInstance.isWatchSessionSupported() {
            print("Watch session is not supported")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let fileManager = FileManager.default
        let fileName = url.lastPathComponent
        
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let destinationUrl = documentsURL.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(at: destinationUrl)
        } catch {
            print(error)
            return false
        }
        do {
            try FileManager.default.copyItem(at: url, to: destinationUrl)
            print("p12 file moved from:", url, "to:", destinationUrl)
            ConfigManager.setCertificateFileName(fileName: fileName)
            NotificationCenter.default.post(name: .newCertificateFile, object: fileName)
        } catch {
            print(error)
            return false
        }
        
        return true
    }
}

