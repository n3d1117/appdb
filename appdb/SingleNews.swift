//
//  SingleNews.swift
//  appdb
//
//  Created by ned on 15/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import RealmSwift
import ObjectMapper

class SingleNews: Object, Mappable {
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var text = ""
    @objc dynamic var added = ""
    
    convenience required init?(map: Map) { self.init() }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    func mapping(map: Map) {
        
        id             <- map["id"]
        title          <- map["title"]
        text           <- map["text"]
        added          <- map["added"]
        
        added = added.unixToString
        title = title.decoded
        
    }
}
