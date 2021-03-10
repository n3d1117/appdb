//
//  AppsWidget.swift
//  WidgetsExtension
//
//  Created by ned on 08/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import Foundation
import WidgetKit
import SwiftUI
import Intents
import Combine
import Localize_Swift

private var cancellables = Set<AnyCancellable>()

struct AppsWidgetsTimelineEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let content: AppdbSearchResource.Response?
}

struct AppsWidgetsProvider: IntentTimelineProvider {

    typealias Entry = AppsWidgetsTimelineEntry

    let appdbRepository = AppdbRepository()

    func placeholder(in context: Context) -> AppsWidgetsTimelineEntry {
        Entry(date: Date(), configuration: ConfigurationIntent(), content: nil)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> Void) {
        completion(Entry(date: Date(), configuration: configuration, content: nil))
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {

        appdbRepository.fetchAPIResource(AppdbSearchResource(configuration.type, configuration.order, configuration.price))
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: {
                switch $0 {
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(Timeline(entries: [], policy: .atEnd))
                default: break
                }
            }, receiveValue: {
                let entries = [
                    Entry(date: Date(), configuration: configuration, content: $0)
                ]
                let nextUpdate = Calendar.autoupdatingCurrent.date(byAdding: .hour, value: 6, to: Calendar.autoupdatingCurrent.startOfDay(for: Date()))!
                let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
                completion(timeline)
            })
            .store(in: &cancellables)
    }
}

struct AppsWidgetsEntryView: View {

    var entry: AppsWidgetsProvider.Entry

    var orderString: String {
        switch entry.configuration.order {
        case .recent: return "Recently Uploaded".localized()
        case .today: return "Popular Today".localized()
        case .week: return "Popular This Week".localized()
        case .month: return "Popular This Month".localized()
        case .year: return "Popular This Year".localized()
        case .all_time: return "Popular All Time".localized()
        case .unknown: return ""
        }
    }

    var typeString: String {
        switch entry.configuration.type {
        case .ios: return "iOS".localized()
        case .cydia: return "Cydia".localized()
        case .books: return "Books".localized()
        case .unknown: return ""
        }
    }

    var body: some View {
        if entry.content == nil || entry.content!.data.isEmpty {
            let dummyData = [Content](repeating: Content.dummy, count: 25)
            AppsWidgetsMainContentView(date: entry.date, header: orderString, type: typeString, content: dummyData)
                .redacted(reason: .placeholder)
        } else {
            AppsWidgetsMainContentView(date: entry.date, header: orderString, type: typeString, content: entry.content!.data)
        }
    }
}

struct AppsWidgetsMainContentView: View {

    let date: Date
    let header: String
    let type: String
    let content: [Content]
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(spacing: 0) {
            AppsWidgetHeader(date: date, header: header, type: type)
                .padding(.leading)
                .padding(.trailing)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .background(Color("BackgroundColorHeader"))

            Divider()

            if family == .systemSmall {
                let slicedData = Array(content.prefix(3))
                VStack(spacing: 6) {
                    ForEach(0..<slicedData.count) { i in
                        let app = slicedData[i]
                        HStack(spacing: 5) {
                            Text(getMedal(for: i))
                                .font(.system(size: 13))
                                .padding(.leading, 5)
                            AppListView(app: app, contentType: type.lowercased())
                        }
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 8)
            } else {
                let columns = 5
                let rows = family == .systemLarge ? 5 : 2
                GridStack(rows: rows, columns: columns) { row, col in
                    if content.indices.contains(row * columns + col) {
                        let app = content[row * columns + col]
                        AppGridView(app: app, contentType: type.lowercased())
                    }
                }
                .padding(.leading)
                .padding(.trailing)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .background(Color("BackgroundColor"))
    }

    func getMedal(for index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        default: return "🥉"
        }
    }
}

struct AppsWidgets: Widget {

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: "appdb-apps-widget", intent: ConfigurationIntent.self, provider: AppsWidgetsProvider()) { entry in
            AppsWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("AppDB content")
        .description("Show and configure appdb content")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct Apps_Previews: PreviewProvider {

    static var previews: some View {
        let dummyData = [Content](repeating: Content.dummy, count: 25)
        AppsWidgetsMainContentView(date: Date(), header: "", type: "cydia", content: dummyData)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
