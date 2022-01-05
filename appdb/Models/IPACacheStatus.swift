//
//  IPACacheStatus.swift
//  appdb
//
//  Created by ned on 05/01/22.
//  Copyright © 2022 ned. All rights reserved.
//

import ObjectMapper

struct IPACacheStatus: Mappable {

    init?(map: Map) { }

    var sizeHr: String = ""
    var inUpdate = false
    var updatedAt: String = ""

    mutating func mapping(map: Map) {
        sizeHr <- map["size_hr"]
        inUpdate <- map["in_update"]
        updatedAt <- map["updated_at"]
    }
}
