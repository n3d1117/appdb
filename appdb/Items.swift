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
    @objc dynamic var author = ""
    @objc dynamic var text = ""
    @objc dynamic var title = ""
    @objc dynamic var rating = 0.0
    
    convenience init(author: String, text: String, title: String, rating: Double) {
        self.init()
        self.author = author
        self.text = text
        self.title = title
        self.rating = rating
    }
}

class Screenshot: Object {
    @objc dynamic var image = ""
    @objc dynamic var class_ = ""
    @objc dynamic var type = ""
    
    convenience init(src: String, class_: String = "", type: String) {
        self.init()
        self.image = src
        self.class_ = class_
        self.type = type
    }
}

class RelatedContent: Object {
    @objc dynamic var icon = ""
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var artist = ""
    
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
    @objc dynamic var category = ""
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    @objc dynamic var icon = ""
    @objc dynamic var compound: String = ""
    
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
