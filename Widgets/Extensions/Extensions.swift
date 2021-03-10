//
//  Extensions.swift
//  WidgetsExtension
//
//  Created by ned on 09/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import SwiftUI
import Localize_Swift

extension String {
    var rfc2822decoded: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC 2822
        formatter.locale = Locale(identifier: "en_US")
        if let date = formatter.date(from: self) {
            formatter.locale = Locale(identifier: Localize.currentLanguage())
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        return ""
    }
}

struct AppIconShape: Shape {

    var rounded: Bool

    init(rounded: Bool = true) {
        self.rounded = rounded
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let size: CGSize = rounded ? CGSize(width: rect.height * 0.225, height: rect.height * 0.225) : .zero
        path.addRoundedRect(in: rect, cornerSize: size, style: .continuous)
        return path
    }
}
