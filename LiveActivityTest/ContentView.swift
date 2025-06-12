//
//  ContentView.swift
//  LiveActivityTest
//
//  Created by carl on 6/12/25.
//

import SwiftUI
import ActivityKit

func startLiveActivity() {
    let attributes = MyAttributes(name: "Carl")
    let contentState = MyAttributes.ContentState(status: "Starting")

    do {
        let activity = try Activity<MyAttributes>.request(
            attributes: attributes,
            content: .init(state: contentState, staleDate: nil),
            pushType: nil
        )
        print("Live Activity started: \(activity.id)")
    } catch {
        print("Failed to start Live Activity: \(error)")
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            Button("Start Live Activity") {
                startLiveActivity()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
