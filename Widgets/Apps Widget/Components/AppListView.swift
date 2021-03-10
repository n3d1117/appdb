//
//  AppListView.swift
//  WidgetsExtension
//
//  Created by ned on 09/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import SwiftUI

struct AppListView: View {
    let app: Content
    let contentType: String

    var body: some View {
        HStack {
            RemoteImage(urlString: app.image)
                .animation(.easeInOut(duration: 0.25))
                .scaledToFit()
                .clipShape(AppIconShape(rounded: contentType != "books"))

            Text(app.name)
                .font(.system(size: 12))
                .lineLimit(2)
                .padding(.trailing, 10)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}
