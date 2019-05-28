//
//  SingleNews.swift
//  appdb
//
//  Created by ned on 15/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import ObjectMapper

struct SingleNews: Mappable {

    init?(map: Map) { }

    var id: String = ""
    var title: String = ""
    var text: String = ""
    var added: String = ""

    mutating func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        text <- map["text"]
        added <- map["added"]

        added = added.unixToString
        title = title.decoded
    }
}
