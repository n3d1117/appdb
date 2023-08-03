//
//  App.swift
//  WidgetsExtension
//
//  Created by ned on 08/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import Foundation

struct Content: Identifiable, Decodable {

    let id: Int
    let name: String
    let image: String

    static var dummy: Content {
        Content(id: 0, name: "Example Name", image: "")
    }
}
