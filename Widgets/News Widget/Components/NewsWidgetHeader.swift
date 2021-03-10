//
//  NewsWidgetHeader.swift
//  WidgetsExtension
//
//  Created by ned on 10/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import SwiftUI

struct NewsWidgetHeader: View {

    let date: Date
    let header: String
    @Environment(\.widgetFamily) var family

    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        HStack {
            HStack(spacing: 7) {
                Image("appdb")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                    .scaledToFit()
                    .clipShape(AppIconShape())
                    .unredacted()
                Text(header)
                    .lineLimit(1)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .fixedSize()
            }
            Spacer()
            if family != .systemSmall {
                Text(formatter.string(from: date))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
    }
}
