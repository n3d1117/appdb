//
//  RemoteImage.swift
//  WidgetsExtension
//
//  Created by ned on 09/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import SwiftUI

// https://github.com/pawello2222/WidgetExamples/blob/main/WidgetExtension/URLImageWidget/URLImageView.swift
struct RemoteImage: View {

    let urlString: String

    @ViewBuilder
    var body: some View {
        if let url = URL(string: urlString),
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            // todo corner
            Image("appdb")
                .resizable()
                .redacted(reason: .placeholder)
        }
    }
}
