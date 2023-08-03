//
//  AltStoreRepo.swift
//  appdb
//
//  Created by stev3fvcks on 17.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit
import ObjectMapper
import Localize_Swift

struct AltStoreRepo: Mappable {

    init?(map: Map) { }

    var id: String = ""
    var name: String = ""
    var identifier: String = ""
    var url: String = ""
    var isPublic = false
    var statusTranslated: String = ""
    var statusString: String = ""
    var status: Status = .ok
    var totalApps: String = "0"
    var addedAt: String = ""
    var lastCheckedAt: String = ""
    var contents: AltStoreRepoContents?
    var apps: [AltStoreApp]? = []

    enum Status: String {
        case ok

        var prettified: String {
            switch self {
            case .ok: return "✓ " + "OK".localized()
            }
        }
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        identifier <- map["identifier"]
        url <- map["url"]
        statusString <- map["status"]
        statusTranslated <- map["status_translated"]
        totalApps <- map["total_apps"]
        addedAt <- map["added_at"]
        lastCheckedAt <- map["last_checked_at"]
        contents <- map["contents"]
        isPublic <- map["is_public"]
        apps = contents?.apps

        name = name.decoded

        status = Status(rawValue: statusString) ?? .ok

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Localize.currentLanguage())
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        let addedDate = addedAt.unixToDate
        addedAt = dateFormatter.string(from: addedDate)

        let lastCheckedDate = lastCheckedAt.unixToDate
        lastCheckedAt = dateFormatter.string(from: lastCheckedDate)
    }
}
