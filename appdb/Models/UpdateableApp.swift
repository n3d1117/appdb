//
//  UpdateableApp.swift
//  appdb
//
//  Created by ned on 10/11/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import SwiftyJSON
import ObjectMapper

struct UpdateableApp: Equatable {

    init?(map: Map) { }

    var itemType: ItemType = .ios

    var versionOld: String = ""
    var versionNew: String = ""
    var alongsideId: String = ""
    var trackid: String = ""
    var image: String = ""
    var updateable: Bool = false
    var type: String = ""
    var name: String = ""
    var whatsnew: String = ""
    var date: String = ""

    var isIgnored: Bool {
        !Preferences.ignoredUpdateableApps.filter({ $0.trackid == trackid }).isEmpty
    }

    static func == (lhs: UpdateableApp, rhs: UpdateableApp) -> Bool {
        lhs.trackid == rhs.trackid && lhs.type == rhs.type
    }
}

extension UpdateableApp: Mappable {

    mutating func mapping(map: Map) {
        versionOld <- map["version_old"]
        versionNew <- map["version_new"]
        alongsideId <- map["alongside_id"]
        trackid <- map["trackid"]
        image <- map["image"]
        updateable <- map["updateable"]
        type <- map["type"]
        name <- map["name"]
        whatsnew <- map["whatsnew"]
        date <- map["added"]

        itemType = type == "ios" ? .ios : .cydia
    }
}
