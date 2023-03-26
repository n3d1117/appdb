//
//  EnterpriseCertificate.swift
//  appdb
//
//  Created by stev3fvcks on 26.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import Foundation

import Foundation
import ObjectMapper

struct EnterpriseCertificate: Equatable, Codable {

    var id: String = ""
    var name: String = ""

    static func == (lhs: EnterpriseCertificate, rhs: EnterpriseCertificate) -> Bool {
        lhs.id == rhs.id
    }
}

extension EnterpriseCertificate: Mappable {

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
