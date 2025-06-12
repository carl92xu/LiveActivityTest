//
//  LiveActivityAttributes.swift
//  LiveActivityTest
//
//  Created by carl on 6/12/25.
//

import ActivityKit
import Foundation

struct MyAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
        var counter: Double

        var startDate: Date
        var incomeType: Int
        var hourlyRate: Double
        var monthlyIncome: Double
        var taxRate: Double
        var hoursPerDay: Double
        var daysPerMonth: Double
    }

    var name: String
}
