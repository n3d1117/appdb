//
//  PlusPurchaseOption.swift
//  appdb
//
//  Created by stev3fvcks on 17.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import ObjectMapper

struct PlusPurchaseOption: Mappable {

    init?(map: Map) { }

    var type: String = ""
    var price: String = ""
    var link: String = ""
    var name: String = ""
    var html: String = ""
    var isReseller = false
    var requiresDeviceLink = true

    mutating func mapping(map: Map) {
        type <- map["type"]
        price <- map["price"]
        link <- map["link"]
        name <- map["name"]
        html <- map["html"]
        isReseller <- map["is_reseller"]
        requiresDeviceLink <- map["requires_device_link"]
    }
}
