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
        SimpleEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            hourlyRate: 28.0,
            taxRate: 11.0,
            elapsed: 0
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            configuration: configuration,
            hourlyRate: 28.0,
            taxRate: 11.0,
            elapsed: 0
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of entries every 20 seconds
        let currentDate = Date()
        for secondOffset in stride(from: 0, to: 300, by: 20) {
            let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                configuration: configuration,
                hourlyRate: 28.0,
                taxRate: 11.0,
                elapsed: TimeInterval(secondOffset)
            )
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
    let hourlyRate: Double
    let taxRate: Double
    let elapsed: TimeInterval
    
    var totalEarned: Double {
        let netHourly = hourlyRate * (1 - taxRate/100)
        let earningPerSecond = netHourly / 3600
        return elapsed * earningPerSecond
    }
}

struct MyWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("$\(String(format: "%.2f", entry.totalEarned))")
                .font(.title)
                .bold()
            Text("$\(String(format: "%.2f", entry.hourlyRate))/hr")
                .font(.system(size: 24))
            Text("Tax: \(String(format: "%.2f", entry.taxRate))%")
                .font(.headline)
            Text("Time Elapsed: \(String(format: "%.0f", entry.elapsed))")
                .font(.system(size: 12))
        }
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

// Widget Preview
//#Preview(as: .systemSmall) {
//    MyWidget()
//} timeline: {
//    SimpleEntry(date: .now, configuration: .smiley, hourlyRate: 28.0, taxRate: 11.0, elapsed: 0)
//    SimpleEntry(date: .now, configuration: .starEyes, hourlyRate: 28.0, taxRate: 11.0, elapsed: 0)
//}

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
                HStack {
                    Text("$\(String(format: "%.2f", totalEarned))")
                        .font(.title)
                        .bold()
                        .padding(.leading)
                        
                        .foregroundStyle(.primary)
                    Spacer()
                    VStack {
                        Text("$\(String(format: "%.2f", context.state.hourlyRate))/hr")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        Text("Tax: \(String(format: "%.2f", context.state.taxRate))%")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                        Text("Time: \(String(format: "%.0f", newElapsed))s")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing)
//                    .activityBackgroundTint(.primary)
                }
                .padding(.vertical)
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
//                        Text("$\(String(format: "%.2f", context.state.hourlyRate))/hr")
//                        Text("Tax: \(String(format: "%.2f", context.state.taxRate))%")
                        Text("$\(String(format: "%.2f", context.state.counter))")
                            .font(.title)
                            .bold()
                    }
                    .padding()
                }
            } compactLeading: {
                Text("🚽")
            } compactTrailing: {
                Text("$\(String(format: "%.2f", context.state.counter))")
            } minimal: {
                Text("$\(String(format: "%.0f", context.state.counter))")
            }
        }
    }
}


#Preview("Live Activity", as: .dynamicIsland(.expanded), using: MyAttributes(name: "Carl")) {
    LiveActivityWidget()
} contentStates: {
    MyAttributes.ContentState(
        status: "Running",
        counter: 100.0,
        startDate: .now,
        incomeType: 0,
        hourlyRate: 100.0,
        monthlyIncome: 0.0,
        taxRate: 11.0,
        hoursPerDay: 0.0,
        daysPerMonth: 0.0,
        earningPerSecond: 0.0247,
        elapsed: 60
    )
    MyAttributes.ContentState(
        status: "Running",
        counter: 200.0,
        startDate: .now,
        incomeType: 0,
        hourlyRate: 100.0,
        monthlyIncome: 0.0,
        taxRate: 11.0,
        hoursPerDay: 0.0,
        daysPerMonth: 0.0,
        earningPerSecond: 0.0247,
        elapsed: 120
    )
}

#Preview("Live Activity", as: .dynamicIsland(.compact), using: MyAttributes(name: "Carl")) {
    LiveActivityWidget()
} contentStates: {
    MyAttributes.ContentState(
        status: "Running",
        counter: 100.0,
        startDate: .now,
        incomeType: 0,
        hourlyRate: 100.0,
        monthlyIncome: 0.0,
        taxRate: 11.0,
        hoursPerDay: 0.0,
        daysPerMonth: 0.0,
        earningPerSecond: 0.0247,
        elapsed: 60
    )
}

#Preview("Live Activity", as: .dynamicIsland(.minimal), using: MyAttributes(name: "Carl")) {
    LiveActivityWidget()
} contentStates: {
    MyAttributes.ContentState(
        status: "Running",
        counter: 100.0,
        startDate: .now,
        incomeType: 0,
        hourlyRate: 100.0,
        monthlyIncome: 0.0,
        taxRate: 11.0,
        hoursPerDay: 0.0,
        daysPerMonth: 0.0,
        earningPerSecond: 0.0247,
        elapsed: 60
    )
}

#Preview("Live Activity Lock Screen", as: .content, using: MyAttributes(name: "Carl")) {
    LiveActivityWidget()
} contentStates: {
    MyAttributes.ContentState(
        status: "Running",
        counter: 100.0,
        startDate: .now,
        incomeType: 0,
        hourlyRate: 100.0,
        monthlyIncome: 0.0,
        taxRate: 11.0,
        hoursPerDay: 0.0,
        daysPerMonth: 0.0,
        earningPerSecond: 0.0247,
        elapsed: 60
    )
    MyAttributes.ContentState(
        status: "Running",
        counter: 200.0,
        startDate: .now,
        incomeType: 0,
        hourlyRate: 100.0,
        monthlyIncome: 0.0,
        taxRate: 11.0,
        hoursPerDay: 0.0,
        daysPerMonth: 0.0,
        earningPerSecond: 0.0247,
        elapsed: 120
    )
}
