//
//  Item.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import RealmSwift

class Screenshot: Object {
    dynamic var image = ""
    dynamic var class_ = ""
    dynamic var type = ""
    
    convenience init(src: String, class_: String, type: String) {
        self.init()
        self.image = src
        self.class_ = class_
        self.type = type
    }
}

class RelatedApp: Object {
    dynamic var icon = ""
    dynamic var id = ""
    dynamic var name = ""
    dynamic var artist = ""
    
    convenience init(icon: String, id: String, name: String, artist: String) {
        self.init()
        self.icon = icon
        self.id = id
        self.name = name
        self.artist = artist
    }
}

class Category {
    var name = ""
    var id = ""
    convenience init(name: String, id: String) {
        self.init()
        self.name = name
        self.id = id
    }
}

class Genre: Object {
    dynamic var category = ""
    dynamic var id = ""
    dynamic var name = ""
    dynamic var icon = ""
    dynamic var compound: String = ""
    
    convenience init(category: String, id: String, name: String) {
        self.init()
        self.category = category
        self.id = id
        self.name = name
        self.compound = self.id + "-" + self.category
    }
    
    override class func primaryKey() -> String? {
        return "compound"
    }
}

class Version: Object {
    dynamic var number = ""
    let links = List<Link>()
}

class Link: Object {
    dynamic var link = ""
    dynamic var cracker = ""
    dynamic var host = ""
    dynamic var verified = ""
    dynamic var di_compatible = false
    dynamic var id = 0
}
