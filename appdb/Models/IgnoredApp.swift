//
//  IgnoredApp.swift
//  appdb
//
//  Created by ned on 24/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Foundation

struct IgnoredApp: Equatable, Codable {
    
    var trackid: String = ""
    var name: String = ""
    var iconUrl: String = ""
    var type: String = ""
    
    init(trackid: String, name: String, iconUrl: String, type: String) {
        self.trackid = trackid
        self.name = name
        self.iconUrl = iconUrl
        self.type = type
    }
    
    static func == (lhs: IgnoredApp, rhs: IgnoredApp) -> Bool {
        return lhs.trackid == rhs.trackid && lhs.type == rhs.type
    }
}
