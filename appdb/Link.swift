//
//  Link.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift


class Version: Object {
    dynamic var number = ""
    let links = List<Link>()
    
    convenience init(number: String) {
        self.init()
        self.number = number
    }
}

class Link: Object {
    dynamic var link = ""
    dynamic var cracker = ""
    dynamic var host = ""
    dynamic var id = ""
    dynamic var verified = false
    dynamic var di_compatible = false
    dynamic var hidden = false
    dynamic var universal = false
    
    convenience init(link: String, cracker: String, host: String, id: String, verified: Bool, di_compatible: Bool, hidden: Bool, universal: Bool) {
        self.init()
        self.link = link
        self.cracker = cracker
        self.host = host
        self.id = id
        self.verified = verified
        self.di_compatible = di_compatible
        self.hidden = hidden
        self.universal = universal
        
        while self.cracker.hasPrefix(" ") { self.cracker = String(self.cracker.characters.dropFirst()) }
    }
}
