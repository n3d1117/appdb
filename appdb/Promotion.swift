//
//  Promotion.swift
//  appdb
//
//  Created by ned on 26/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import RealmSwift
import ObjectMapper

class Promotion: Object, Mappable {
    
    convenience required init?(map: Map) { self.init() }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id = ""
    @objc dynamic var lead = ""
    @objc dynamic var type = ""
    @objc dynamic var trackid = ""
    @objc dynamic var name = ""
    @objc dynamic var image = ""
    
    func mapping(map: Map) {
        
        id            <- map["id"]
        lead          <- map["lead"]
        type          <- map["type"]
        trackid       <- map["trackid"]
        name          <- map["name"]
        image         <- map["image"]

    }
}
