//
//  ContentView.swift
//  LiveActivityTest
//
//  Created by carl on 6/12/25.
//

import SwiftUI
import ActivityKit

func startLiveActivity(counter: Int, setActivity: @escaping (Activity<MyAttributes>) -> Void) {
    let attributes = MyAttributes(name: "Carl")
    let contentState = MyAttributes.ContentState(status: "Starting", counter: counter)

    do {
        let activity = try Activity<MyAttributes>.request(
            attributes: attributes,
            content: .init(state: contentState, staleDate: nil),
            pushType: nil
        )
        print("Live Activity started: \(activity.id)")
        setActivity(activity)
    } catch {
        print("Failed to start Live Activity: \(error)")
    }
}

struct ContentView: View {
    @State private var counter = 0
    @State private var activity: Activity<MyAttributes>? = nil
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(counter)")
                .font(.system(size: 64, weight: .bold))
                .monospacedDigit()

            Button {
                startLiveActivity(counter: counter) { newActivity in
                    activity = newActivity
                }
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
            if let activity = activity {
                Task {
                    let updatedState = MyAttributes.ContentState(status: "Running", counter: counter)
                    await activity.update(using: updatedState)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
