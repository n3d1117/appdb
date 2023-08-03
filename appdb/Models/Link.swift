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
    var reportReason: String = ""
    var compatibility: String = ""
    var isCompatible = false
    var verified = false
    var diCompatible = false
    var hidden = false
    var universal = false
    var isTicket = false

    init(link: String, cracker: String, uploader: String, host: String, id: String, verified: Bool, di_compatible: Bool, hidden: Bool, universal: Bool, is_compatible: Bool, isTicket: Bool = false, incompatibility_reason: String = "", report_reason: String = "") {
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

        self.isCompatible = is_compatible
        self.compatibility = is_compatible ? "Compatible with your device".localized() : incompatibility_reason
        self.reportReason = report_reason
    }
}
