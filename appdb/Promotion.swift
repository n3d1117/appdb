//
//  Promotion.swift
//  appdb
//
//  Created by ned on 26/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import RealmSwift

class Promotion: Object, Mappable {
    
    convenience required init?(map: Map) { self.init() }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    dynamic var id = ""
    dynamic var lead = ""
    dynamic var type = ""
    dynamic var trackid = ""
    dynamic var name = ""
    dynamic var image = ""
    
    func mapping(map: Map) {
        
        id            <- map["id"]
        lead          <- map["lead"]
        type          <- map["type"]
        trackid       <- map["trackid"]
        name          <- map["name"]
        image         <- map["image"]

    }
}
