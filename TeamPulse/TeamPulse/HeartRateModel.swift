//
//  HeartRateModel.swift
//  TeamPulse
//
//  Created by William Welbes on 2/12/19.
//  Copyright © 2019 William Welbes. All rights reserved.
//

import Foundation

public struct HeartRateModel : Codable {
    public let userName: String
    public let userId: String
    public let heartRate: Int
}
