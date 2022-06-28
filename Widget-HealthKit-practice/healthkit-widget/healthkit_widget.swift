//
//  healthkit_widget.swift
//  healthkit-widget
//
//  Created by Sho Emoto on 2022/06/25.
//

import WidgetKit
import SwiftUI
import Intents
import HealthKit

struct MyHealthProvider: IntentTimelineProvider {

    // MARK: デフォルトのViewで表示するデータを返す
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)

        // HealthKitが利用可能かチェック
        if HKHealthStore.isHealthDataAvailable() {
            // ヘルスケアアプリのデータを取得する処理
            // 今回は歩数を取得
            let healthStore = HKHealthStore()

            let readTypes = Set([
                HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount )!
            ])

            healthStore.requestAuthorization(toShare: [], read: readTypes, completion: {success, error in
                if success == false {
                    print("データにアクセスできません")
                    return
                }

                let calendar = Calendar.current
                let hkTypeStepCount = HKObjectType.quantityType(forIdentifier: .stepCount)!

                let today = calendar.dateComponents([.calendar, .year, .month, .day], from: Date())
                let startDate = DateComponents(year: today.year, month: today.month, day: today.day, hour: 0, minute: 0, second: 0)
                let endDate = DateComponents(year: today.year, month: today.month, day: today.day, hour: 23, minute: 59, second: 59)

                let predicate = HKQuery.predicateForSamples(
                    withStart: calendar.date(from: startDate),
                    end: calendar.date(from: endDate)
                )

                let query = HKSampleQuery(
                    queryDescriptors: [.init(sampleType: hkTypeStepCount, predicate: predicate)],
                    limit: 10,
                    resultsHandler: { query, samples, error in
                        print("<------ debug ------>")
                        print(samples)
                        print(error)
                        print("<------ debug ------>")
                    })

                healthStore.execute(query)
            })

        }
    }
}



struct healthkit_widgetEntryView : View {
    var entry: MyHealthProvider.Entry

    var body: some View {

        VStack(alignment: .leading, spacing: 20) {

            Text("Hello, Widget")
                .font(.title)
                .bold()

            Text(entry.date, style: .time)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .widgetURL(URL(string: "example://widget_deeplink"))


    }
}

@main
struct healthkit_widget: Widget {
    let kind: String = "healthkit_widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: MyHealthProvider()) { entry in
            healthkit_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct healthkit_widget_Previews: PreviewProvider {
    static var previews: some View {
        healthkit_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
