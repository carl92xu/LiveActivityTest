//
//  MyWidget.swift
//  MyWidget
//
//  Created by carl on 6/12/25.
//

import WidgetKit
import SwiftUI
import ActivityKit

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct MyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Text("Time:")
        Text(entry.date, style: .time)

        Text("Favorite Emoji:")
        Text(entry.configuration.favoriteEmoji)
    }
}

struct MyWidget: Widget {
    let kind: String = "MyWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            MyWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    MyWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}


// MARK: - Live Activity

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
        
        var earningPerSecond: Double
        
        var elapsed: TimeInterval
    }

    var name: String
}


struct LiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MyAttributes.self) { context in
            TimelineView(.periodic(from: context.state.startDate, by: 20)) { timeline in
                let newElapsed = context.state.elapsed + timeline.date.timeIntervalSince(context.state.startDate)
                let totalEarned: Double = newElapsed * context.state.earningPerSecond

                // Lock screen/banner UI
                VStack {
    //                Text("$\(String(format: "%.2f", context.state.counter))")
                    Text("$\(String(format: "%.2f", totalEarned))")
                        .font(.title)
                        .bold()
                    Text("$\(String(format: "%.2f", context.state.hourlyRate))/hr")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                    Text("Tax: \(String(format: "%.2f", context.state.taxRate))%")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("newElapsed: \(String(format: "%.2f", newElapsed))")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .activityBackgroundTint(.blue)
                .activitySystemActionForegroundColor(.white)
            }
        }
        
        dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text("$\(String(format: "%.2f", context.state.hourlyRate))/hr")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Tax: \(String(format: "%.2f", context.state.taxRate))%")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack {
                        Text("$\(String(format: "%.2f", context.state.hourlyRate))/hr")
                        Text("Tax: \(String(format: "%.2f", context.state.taxRate))%")
                        Text("$\(String(format: "%.2f", context.state.counter))")
                    }
                }
            } compactLeading: {
                Text("🚽")
                //Text("🧻")
            } compactTrailing: {
                Text("$\(String(format: "%.2f", context.state.counter))")
            } minimal: {
                Text("$\(String(format: "%.0f", context.state.counter))")
            }
        }
    }
}
