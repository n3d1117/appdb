//
//  Item.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import ObjectMapper

class Item: Hashable, Mappable {

    required init?(map: Map) { }
    func mapping(map: Map) { }

    var id: String = ""

    class func type() -> ItemType {
        return .ios // Default implementation
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id // Default implementation
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Review {
    var author: String = ""
    var text: String = ""
    var title: String = ""
    var rating: Double = 0.0

    init(author: String, text: String, title: String, rating: Double) {
        self.author = author
        self.text = text
        self.title = title
        self.rating = rating
    }
}

struct Screenshot {
    var image: String = ""
    var class_: String = ""
    var type: String = ""

    init(src: String, class_: String = "", type: String) {
        self.image = src
        self.class_ = class_
        self.type = type
    }
}

struct RelatedContent {
    var icon: String = ""
    var id: String = ""
    var name: String = ""
    var artist: String = ""

    init(icon: String, id: String, name: String, artist: String) {
        self.icon = icon
        self.id = id
        self.name = name
        self.artist = artist
    }
}

struct Category {
    var name: String = ""
    var id: String = ""

    init(name: String, id: String) {
        self.name = name
        self.id = id
    }
}

struct Genre: Equatable, Codable {
    var category: String = ""
    var id: String = ""
    var name: String = ""
    var icon: String = ""
    var compound: String = ""

    init(category: String, id: String, name: String) {
        self.category = category
        self.id = id
        self.name = name
        self.compound = self.id + "-" + self.category
    }

    static func == (lhs: Genre, rhs: Genre) -> Bool {
        return lhs.compound == rhs.compound
    }
}
