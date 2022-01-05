//
//  NewsWidget.swift
//  WidgetsExtension
//
//  Created by ned on 09/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import Foundation
import WidgetKit
import SwiftUI
import Intents
import Combine
import Localize_Swift

private var cancellables = Set<AnyCancellable>()

struct NewsWidgetsTimelineEntry: TimelineEntry {
    let date: Date
    let content: AppdbNewsResource.Response?
}

struct NewsWidgetsProvider: TimelineProvider {

    typealias Entry = NewsWidgetsTimelineEntry

    let appdbRepository = AppdbRepository()

    func placeholder(in context: Context) -> NewsWidgetsTimelineEntry {
        Entry(date: Date(), content: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (NewsWidgetsTimelineEntry) -> Void) {
        completion(Entry(date: Date(), content: nil))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NewsWidgetsTimelineEntry>) -> Void) {
        appdbRepository.fetchAPIResource(AppdbNewsResource())
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
                    Entry(date: Date(), content: $0)
                ]
                let nextUpdate = Calendar.autoupdatingCurrent.date(byAdding: .hour, value: 6, to: Calendar.autoupdatingCurrent.startOfDay(for: Date()))!
                let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
                completion(timeline)
            })
            .store(in: &cancellables)
    }
}

struct NewsWidgetsEntryView: View {

    var entry: NewsWidgetsProvider.Entry

    var body: some View {
        if entry.content == nil || entry.content!.data.isEmpty {
            let dummyData = [News](repeating: News.dummy, count: 10)
            NewsWidgetsMainContentView(date: entry.date, content: dummyData)
                .redacted(reason: .placeholder)
        } else {
            NewsWidgetsMainContentView(date: entry.date, content: entry.content!.data)
        }
    }
}

struct NewsWidgetsMainContentView: View {

    let date: Date
    let content: [News]
    @Environment(\.widgetFamily) var family

    var newsCount: Int {
        switch family {
        case .systemSmall: return 1
        case .systemMedium: return 3
        case .systemLarge: return 8
        case .systemExtraLarge: return 0 // not supported
        @unknown default: return 3
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            NewsWidgetHeader(date: date, header: "News".localized())
                .padding(.leading)
                .padding(.trailing)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .background(Color("BackgroundColorHeader"))

            Divider()

            if family == .systemSmall {
                if let latestNews = content.first {
                    let redirectUrl = "appdb-ios://?news_id=\(latestNews.id)"

                    VStack(alignment: .leading, spacing: 2) {
                        Text(latestNews.added.rfc2822decoded)
                            .lineLimit(1)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(alignment: .leading)
                        Text(latestNews.title)
                            .font(.system(size: 17))
                            .lineLimit(4)
                            .frame(alignment: .leading)
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.bottom, 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .widgetURL(URL(string: redirectUrl)!)
                }
            } else {
                VStack {
                    let data = Array(content.prefix(newsCount))
                    ForEach(0..<data.count) { i in

                        let news = data[i]
                        let redirectUrl = "appdb-ios://?news_id=\(news.id)"

                        Link(destination: URL(string: redirectUrl)!) {
                            HStack {
                                Text(news.title)
                                    .lineLimit(1)
                                    .font(.system(size: 14))
                                Spacer()
                                Text(news.added.rfc2822decoded)
                                    .lineLimit(1)
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxHeight: .infinity)
                        }
                        if i < data.count - 1 {
                            Divider()
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 10)
                .padding(.leading)
                .padding(.trailing)
            }
        }
        .background(Color("BackgroundColor"))
    }
}

struct NewsWidgets: Widget {

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "appdb-news-widget", provider: NewsWidgetsProvider()) { entry in
            NewsWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("AppDB News")
        .description("Show recent appdb news")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct News_Previews: PreviewProvider {

    static var previews: some View {
        let dummyData = [News](repeating: News.dummy, count: 10)
        NewsWidgetsMainContentView(date: Date(), content: dummyData)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        NewsWidgetsMainContentView(date: Date(), content: dummyData)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
