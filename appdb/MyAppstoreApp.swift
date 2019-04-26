//
//  MyAppstoreApp.swift
//  appdb
//
//  Created by ned on 26/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import RealmSwift
import SwiftyJSON
import ObjectMapper

class MyAppstoreApp: Object, Meta {
    
    convenience required init?(map: Map) { self.init() }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    static func type() -> ItemType {
        return .myAppstore
    }
    
    @objc dynamic var name = ""
    @objc dynamic var id = ""
    @objc dynamic var bundleId = ""
    @objc dynamic var version = ""
    @objc dynamic var uploadedAt = ""
    @objc dynamic var size = ""
    
}

extension MyAppstoreApp: Mappable {
    func mapping(map: Map) {
        
        name                    <- map["name"]
        id                      <- map["id"]
        bundleId                <- map["bundle_id"]
        version                 <- map["bundle_version"]
        uploadedAt              <- map["uploaded_at"]
        size                    <- map["size"]
        
        if let doubleSize = Double(size) {
            size = Global.humanReadableSize(bytes: doubleSize)
        }
        
    }
}
