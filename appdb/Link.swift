//
//  Link.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import RealmSwift

class Version: Object {
    @objc dynamic var number = ""
    let links = List<Link>()
    
    convenience init(number: String) {
        self.init()
        self.number = number
    }
}

class Link: Object {
    @objc dynamic var link = ""
    @objc dynamic var cracker = ""
    @objc dynamic var host = ""
    @objc dynamic var id = ""
    @objc dynamic var verified = false
    @objc dynamic var di_compatible = false
    @objc dynamic var hidden = false
    @objc dynamic var universal = false
    
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
        
        while self.cracker.hasPrefix(" ") { self.cracker = String(self.cracker.dropFirst()) }
        if self.cracker == "" { self.cracker = "Unknown".localized() }
    }
}
