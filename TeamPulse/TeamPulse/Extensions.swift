//
//  Extensions.swift
//  TeamPulse
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let newCertificateFile = Notification.Name("newCertificateFile")
    static let newHeartRateWatch = Notification.Name("newHeartRateWatch")
    static let newHeartRateMQTT = Notification.Name("newHeartRateMQTT")
}
