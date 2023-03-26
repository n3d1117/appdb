//
//  CachedIPA.swift
//  appdb
//
//  Created by stev3fvcks on 26.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import Foundation
import ObjectMapper
import Localize_Swift

struct CachedIPA: Mappable {

    init?(map: Map) { }

    var bundleId: String = ""
    var name: String = ""
    var size: Int = 0
    var sizeHr: String = ""
    var addedAt: String = ""

    mutating func mapping(map: Map) {
        bundleId <- map["bundle_id"]
        name <- map["name"]
        size <- map["size"]
        sizeHr <- map["size_hr"]
        addedAt <- map["added_at"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Localize.currentLanguage())
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let date = addedAt.unixToDate
        addedAt = dateFormatter.string(from: date)
    }
}
