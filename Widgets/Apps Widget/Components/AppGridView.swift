//
//  AppGridView.swift
//  WidgetsExtension
//
//  Created by ned on 09/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import SwiftUI

struct AppGridView: View {

    let app: Content
    let contentType: String

    var body: some View {

        let redirectUrl = "appdb-ios://?trackid=\(app.id)&type=\(contentType)"

        VStack {
            Link(destination: URL(string: redirectUrl)!) {
                RemoteImage(urlString: app.image)
                    .animation(.easeInOut(duration: 0.25))
                    .scaledToFit()
                    .clipShape(AppIconShape(rounded: contentType != "books"))
            }
        }
    }
}
