//
//  LinkedDevice.swift
//  appdb
//
//  Created by ned on 13/06/21.
//  Copyright © 2021 ned. All rights reserved.
//

import Foundation
import ObjectMapper

struct LinkedDevice: Equatable, Codable {

    var model: String = ""
    var niceIdeviceModel: String = ""
    var linkToken: String = ""
    var iosVersion: String = ""
    var name: String = ""
    var isPro = false

    static func == (lhs: LinkedDevice, rhs: LinkedDevice) -> Bool {
        lhs.linkToken == rhs.linkToken
    }
}

extension LinkedDevice: Mappable {

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        model <- map["model"]
        niceIdeviceModel <- map["nice_idevice_model"]
        linkToken <- map["link_token"]
        iosVersion <- map["ios_version"]
        name <- map["name"]
        isPro = map["is_pro"].value() == "yes"
    }
}
