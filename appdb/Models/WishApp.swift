//
//  WishApp.swift
//  appdb
//
//  Created by ned on 07/07/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import ObjectMapper
import Localize_Swift

struct WishApp: Mappable {

    init?(map: Map) { }

    var id: String = ""
    var trackid: String = ""
    var version: String = ""
    var image: String = ""
    var name: String = ""
    var requestersAmount: String = ""
    var price: String = ""
    var statusString: String = ""
    var status: Status = .new
    var statusChangedAt: String = ""
    var bundleId: String = ""

    enum Status: String {
        case cracking, fulfilled, failed, new

        var prettified: String {
            switch self {
            case .new: return "New".localized()
            case .cracking: return "⚙︎ " + "Processing".localized()
            case .failed: return "𐄂 " + "Failed".localized()
            case .fulfilled: return "✓ " + "Fulfilled".localized()
            }
        }
    }

    mutating func mapping(map: Map) {
        id <- map["id"]
        trackid <- map["trackid"]
        version <- map["version"]
        image <- map["image"]
        name <- map["name"]
        requestersAmount <- map["requesters_amount"]
        price <- map["price"]
        statusString <- map["status"]
        statusChangedAt <- map["status_changed_at"]
        bundleId <- map["bundle_id"]

        name = name.decoded

        price = price == "0.00" ? "Free".localized() : price

        status = Status(rawValue: statusString) ?? .new

        let date = statusChangedAt.unixToDate
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Localize.currentLanguage())
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        statusChangedAt = dateFormatter.string(from: date)
    }
}
