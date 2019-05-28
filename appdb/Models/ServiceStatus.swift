//
//  ServiceStatus.swift
//  appdb
//
//  Created by ned on 05/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import ObjectMapper

struct ServiceStatus: Mappable {
    
    init?(map: Map) { }

    var name: String = ""
    var isOnline: Bool = false

    mutating func mapping(map: Map) {
        name <- map["name"]
        isOnline <- map["is_online"]
    }
}
