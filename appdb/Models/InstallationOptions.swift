//
//  InstallationOptions.swift
//  appdb
//
//  Created by stev3fvcks on 19.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import ObjectMapper

enum InstallationOptionIdentifier: String {
    case alongside = "alongside"
    case name = "name"
    case inapp = "inapp"
    case trainer = "trainer"
    case removePlugins = "remove_plugins"
    case push = "push"
    case injectDylibs = "inject_dylibs"
}

enum InstallationOptionType: String {
    case string = "string"
    case boolean = "boolean"
    case multiple = "multiple"
}

struct InstallationOption: Mappable {

    init?(map: Map) { }

    var identifier: InstallationOptionIdentifier = .alongside
    var identifierString: String = ""
    var question: String = ""
    var type: InstallationOptionType = .string
    var typeString: String = ""
    var placeholder: String = ""
    var chooseFrom: [String] = []

    mutating func mapping(map: Map) {
        identifierString <- map["identifier"]
        typeString <- map["type"]
        question <- map["question"]
        type <- map["type"]
        placeholder <- map["placeholder"]
        chooseFrom <- map["choose_from"]
        
        identifier = InstallationOptionIdentifier(rawValue: identifierString) ?? .alongside
        type = InstallationOptionType(rawValue: typeString) ?? .string
    }
}
