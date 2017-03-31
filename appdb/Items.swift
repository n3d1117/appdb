//
//  Item.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import RealmSwift

class Review: Object {
    dynamic var author = ""
    dynamic var text = ""
    dynamic var title = ""
    dynamic var rating = 0.0
    
    convenience init(author: String, text: String, title: String, rating: Double) {
        self.init()
        self.author = author
        self.text = text
        self.title = title
        self.rating = rating
    }
}

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

class RelatedContent: Object {
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
