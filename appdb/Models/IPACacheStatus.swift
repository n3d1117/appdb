//
//  IPACacheStatus.swift
//  appdb
//
//  Created by ned on 05/01/22.
//  Copyright © 2022 ned. All rights reserved.
//

import ObjectMapper
import Localize_Swift

struct IPACacheStatus: Mappable {

    init?(map: Map) { }

    var sizeHr: String = ""
    var sizeLimitHr: String = ""
    var inUpdate = false
    var updatedAt: String = ""
    var ipas: [CachedIPA] = []

    mutating func mapping(map: Map) {
        sizeHr <- map["size_hr"]
        sizeLimitHr <- map["size_limit_hr"]
        inUpdate <- map["in_update"]
        updatedAt <- map["updated_at"]
        ipas <- map["ipas"]

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Localize.currentLanguage())
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let date = updatedAt.unixToDate
        updatedAt = dateFormatter.string(from: date)
    }
}
