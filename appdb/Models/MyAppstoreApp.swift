//
//  MyAppStoreApp.swift
//  appdb
//
//  Created by ned on 26/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import SwiftyJSON
import ObjectMapper

class MyAppStoreApp: Item {
    
    required init?(map: Map) { }

    override class func type() -> ItemType {
        return .myAppstore
    }

    override var id: String {
        get { return super.id }
        set { super.id = newValue }
    }

    var name: String = ""
    var bundleId: String = ""
    var version: String = ""
    var uploadedAt: String = ""
    var size: String = ""
}

extension MyAppStoreApp: Mappable {
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        bundleId <- map["bundle_id"]
        version <- map["bundle_version"]
        uploadedAt <- map["uploaded_at"]
        size <- map["size"]

        if let int64size = Int64(size) {
            size = Global.humanReadableSize(bytes: int64size)
        }
    }
}
