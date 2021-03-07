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
        lhs.number == rhs.number
    }
}

struct Link {
    var link: String = ""
    var cracker: String = ""
    var uploader: String = ""
    var host: String = ""
    var id: String = ""
    var verified: Bool = false
    var diCompatible: Bool = false
    var hidden: Bool = false
    var universal: Bool = false
    var isTicket: Bool = false

    init(link: String, cracker: String, uploader: String, host: String, id: String, verified: Bool, di_compatible: Bool, hidden: Bool, universal: Bool, isTicket: Bool = false) {
        self.link = link
        self.cracker = cracker
        self.uploader = uploader
        self.host = host
        self.id = id
        self.verified = verified
        self.diCompatible = di_compatible
        self.hidden = hidden
        self.universal = universal
        self.isTicket = isTicket

        while self.cracker.hasPrefix(" ") { self.cracker = String(self.cracker.dropFirst()) }
        if self.cracker.isEmpty { self.cracker = "Unknown".localized() }

        while self.uploader.hasPrefix(" ") { self.uploader = String(self.uploader.dropFirst()) }
        if self.uploader.isEmpty { self.uploader = "Unknown".localized() }
    }
}
