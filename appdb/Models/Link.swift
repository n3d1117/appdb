//
//  Link.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation

struct Version: Equatable {
    var number: String = ""
    var links = [Link]()

    init(number: String) {
        self.number = number
    }

    static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.number == rhs.number
    }
}

struct Link {
    var link: String = ""
    var cracker: String = ""
    var host: String = ""
    var id: String = ""
    var verified: Bool = false
    var diCompatible: Bool = false
    var hidden: Bool = false
    var universal: Bool = false

    init(link: String, cracker: String, host: String, id: String, verified: Bool, di_compatible: Bool, hidden: Bool, universal: Bool) {
        self.link = link
        self.cracker = cracker
        self.host = host
        self.id = id
        self.verified = verified
        self.diCompatible = di_compatible
        self.hidden = hidden
        self.universal = universal

        while self.cracker.hasPrefix(" ") { self.cracker = String(self.cracker.dropFirst()) }
        if self.cracker.isEmpty { self.cracker = "Unknown".localized() }
    }
}
