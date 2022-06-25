//
//  healthkit_widget.swift
//  healthkit-widget
//
//  Created by Sho Emoto on 2022/06/25.
//

import WidgetKit
import SwiftUI
import Intents

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
