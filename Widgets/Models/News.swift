//
//  News.swift
//  WidgetsExtension
//
//  Created by ned on 09/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import Foundation

struct News: Identifiable, Decodable {

    let id: Int
    let title: String
    let added: String

    static var dummy: News {
        News(id: 0, title: "Example News Title Goes Here", added: "Tue, 16 Feb 2021 14:30:48 +0000")
    }
}
