//
//  ConfigManager.swift
//  TeamPulse
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation

class ConfigManager {
    
    class func userName() -> String? {
        return UserDefaults.standard.string(forKey: "userName")
    }
    
    class func setUserName(userName: String?) {
        UserDefaults.standard.setValue(userName, forKey: "userName")
        UserDefaults.standard.synchronize()
    }
    
    class func userId() -> String? {
        return UserDefaults.standard.string(forKey: "userId")
    }
    
    class func setUserId(userId: String) {
        UserDefaults.standard.setValue(userId, forKey: "userId")
        UserDefaults.standard.synchronize()
    }
}
