//
//  RoundedBadge.swift
//  WidgetsExtension
//
//  Created by ned on 09/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import SwiftUI

struct RoundedBadge: View {

    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .kerning(0.5)
            .foregroundColor(.white)
            .padding(.top, 2)
            .padding(.bottom, 2)
            .padding(.leading, 6)
            .padding(.trailing, 6)
            .lineLimit(1)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .foregroundColor(.accentColor)
            )
    }
}
