//
//  LiveActivityAttributes.swift
//  LiveActivityTest
//
//  Created by carl on 6/12/25.
//

import ActivityKit

struct MyAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: String
    }

    var name: String
}
