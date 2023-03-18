//
//  AltStoreRepoContents.swift
//  appdb
//
//  Created by stev3fvcks on 17.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import ObjectMapper
import Localize_Swift
import UIKit

struct AltStoreRepoContents: Mappable {

    init?(map: Map) { }

    var apps: [AltStoreApp] = []

    mutating func mapping(map: Map) {
        apps <- map["apps"]
    }
}
