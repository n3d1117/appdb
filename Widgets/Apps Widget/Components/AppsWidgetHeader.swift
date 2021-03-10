//
//  AppsWidgetHeader.swift
//  WidgetsExtension
//
//  Created by ned on 09/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import SwiftUI

struct AppsWidgetHeader: View {

    let date: Date
    let header: String
    let type: String
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
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .unredacted()
                Text(family == .systemSmall ? "Top 3" : header)
                    .lineLimit(1)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .fixedSize()
                if !properUppercase(type).isEmpty {
                    RoundedBadge(text: properUppercase(type))
                        .fixedSize()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Spacer()
            if family != .systemSmall {
                Text(formatter.string(from: date))
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
        }
    }

    func properUppercase(_ string: String) -> String {
        if string == "iOS".localized() { return string }
        return string.uppercased()
    }
}
