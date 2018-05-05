//
//  ServiceStatus.swift
//  appdb
//
//  Created by ned on 05/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import RealmSwift
import ObjectMapper

class ServiceStatus: Object, Mappable {
    @objc dynamic var name = ""
    @objc dynamic var isOnline = false
    
    convenience required init?(map: Map) { self.init() }
    
    override class func primaryKey() -> String? {
        return "name"
    }
    
    func mapping(map: Map) {
        name             <- map["name"]
        isOnline         <- map["is_online"]
    }
}
