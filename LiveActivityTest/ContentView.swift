//
//  ContentView.swift
//  LiveActivityTest
//
//  Created by carl on 6/12/25.
//

import SwiftUI
import ActivityKit

func startLiveActivity(counter: Int) {
    let attributes = MyAttributes(name: "Carl")
    let contentState = MyAttributes.ContentState(status: "Starting", counter: counter)

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
    @State private var counter = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(counter)")
                .font(.system(size: 64, weight: .bold))
                .monospacedDigit()

            Button {
                startLiveActivity(counter: counter)
            } label: {
                Text("Start Live Activity")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .onReceive(timer) { _ in
            counter += 1
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
