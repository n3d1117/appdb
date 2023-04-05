//
//  CydiaApp.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import SwiftyJSON
import ObjectMapper

class CydiaApp: Item {

    required init?(map: Map) {
        super.init(map: map)
    }

    override var id: String {
        get { super.id }
        set { super.id = newValue }
    }

    override class func type() -> ItemType {
        .cydia
    }

    static func == (lhs: CydiaApp, rhs: CydiaApp) -> Bool {
        lhs.id == rhs.id && lhs.version == rhs.version
    }

    var screenshotsData: String = ""

    var name: String = ""
    var image: String = ""

    // General
    var categoryId: String = ""
    var developer: String = ""
    var developerId: String = ""

    // Text
    var description_: String = ""
    var whatsnew: String = ""

    // Information
    var bundleId: String = ""
    var version: String = ""
    var price: String = ""
    var updated: String = ""

    // Tweaked
    var originalTrackid: String = ""
    var originalSection: String = ""
    var isTweaked = false

    // Screenshots
    var screenshotsIphone = [Screenshot]()
    var screenshotsIpad = [Screenshot]()
    
    // Download stats
    var clicksDay: String = "0"
    var clicksWeek: String = "0"
    var clicksMonth: String = "0"
    var clicksYear: String = "0"
    var clicksAll: String = "0"

    override func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        image <- map["image"]
        bundleId <- map["bundle_id"]
        developer <- map["pname"]
        developerId <- map["artist_id"]
        version <- map["version"]
        price <- map["price"]
        categoryId <- map["genre_id"]
        updated <- map["added"]
        description_ <- map["description"]
        whatsnew <- map["whatsnew"]
        originalTrackid <- map["original_trackid"]
        originalSection <- map["original_section"]
        screenshotsData <- map["screenshots"]

        isTweaked = originalTrackid != "0"
        if developer.hasSuffix(" ") { developer = String(developer.dropLast()) }

        if let data = screenshotsData.data(using: .utf8), let screenshotsParse = try? JSON(data: data) {
            // Screenshots
            var tmpScreens = [Screenshot]()
            for i in 0..<screenshotsParse["iphone"].count {
                tmpScreens.append(Screenshot(
                    src: screenshotsParse["iphone"][i]["src"].stringValue,
                    class_: screenshotsParse["iphone"][i]["class"].stringValue,
                    type: "iphone"
                ))
            }; screenshotsIphone = tmpScreens

            var tmpScreensIpad = [Screenshot]()
            for i in 0..<screenshotsParse["ipad"].count {
                tmpScreensIpad.append(Screenshot(
                    src: screenshotsParse["ipad"][i]["src"].stringValue,
                    class_: screenshotsParse["ipad"][i]["class"].stringValue,
                    type: "ipad"
                ))
            }; screenshotsIpad = tmpScreensIpad
        }
        
        clicksDay <- map["clicks_day"]
        clicksWeek <- map["clicks_week"]
        clicksMonth <- map["clicks_month"]
        clicksYear <- map["clicks_year"]
        clicksAll <- map["clicks_all"]
    }
}
