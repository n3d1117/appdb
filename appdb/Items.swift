//
//  Item.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    dynamic var name = ""
    dynamic var trackid = ""
    dynamic var icon = ""
}

class Screenshot: Object {
    dynamic var image = ""
    dynamic var class_ = ""
}

class RelatedApp: Object {
    dynamic var icon = ""
    dynamic var trackid = ""
    dynamic var name = ""
    dynamic var artist = ""
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
