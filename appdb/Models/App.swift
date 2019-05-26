//
//  App.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import SwiftyJSON
import ObjectMapper

class App: Item {
    required init?(map: Map) { }

    override var id: String {
        get { return super.id }
        set { super.id = newValue }
    }

    override class func type() -> ItemType {
        return .ios
    }

    static func == (lhs: App, rhs: App) -> Bool {
        return lhs.id == rhs.id && lhs.version == rhs.version
    }

    var name: String = ""
    var image: String = ""

    // iTunes data
    var lastParseItunes: String = ""
    var screenshotsData: String = ""

    // General
    var category: Category?
    var seller: String = ""

    // Text cells
    var description_: String = ""
    var whatsnew: String = ""

    // Dev apps
    var artistId: String = ""
    var genreId: String = ""

    // Copyright notice
    var publisher: String = ""
    var pname: String = ""

    // Information
    var bundleId: String = ""
    var updated: String = ""
    var published: String = ""
    var version: String = ""
    var price: String = ""
    var size: String = ""
    var rated: String = ""
    var compatibility: String = ""
    var languages: String = ""

    // Support links
    var website: String = ""
    var support: String = ""

    // Ratings
    var numberOfRating: String = ""
    var numberOfStars: Double = 0.0

    // Screenshots
    var screenshotsIphone = [Screenshot]()
    var screenshotsIpad = [Screenshot]()
}

extension App: Mappable {
    func mapping(map: Map) {
        name <- map["name"]
        id <- map["id"]
        image <- map["image"]
        bundleId <- map["bundle_id"]
        version <- map["version"]
        price <- map["price"]
        updated <- map["added"]
        genreId <- map["genre_id"]
        artistId <- map["artist_id"]
        description_ <- map["description"]
        whatsnew <- map["whatsnew"]
        screenshotsData <- map["screenshots"]
        lastParseItunes <- map["last_parse_itunes"]
        website <- map["pwebsite"]
        support <- map["psupport"]
        pname <- map["pname"]

        // Information

        if let data = lastParseItunes.data(using: .utf8), let itunesParse = try? JSON(data: data) {
            seller = itunesParse["seller"].stringValue
            size = itunesParse["size"].stringValue
            publisher = itunesParse["publisher"].stringValue
            published = itunesParse["published"].stringValue
            rated = itunesParse["censor_rating"].stringValue
            compatibility = itunesParse["requirements"].stringValue
            languages = itunesParse["languages"].stringValue
            category = Category(name: itunesParse["genre"]["name"].stringValue, id: itunesParse["genre"]["id"].stringValue)

            if languages.contains("Watch") { languages = "".localized() } /* dirty fix "Languages: Apple Watch: Yes" */
            while published.hasPrefix(" ") { published = String(published.dropFirst()) }

            // Ratings
            if !itunesParse["ratings"]["count"].stringValue.isEmpty {
                let count = itunesParse["ratings"]["count"].intValue
                numberOfRating = "(" + NumberFormatter.localizedString(from: NSNumber(value: count), number: .decimal) + ")"
                numberOfStars = itunesParse["ratings"]["stars"].doubleValue
            }
        } else {
            // Pulled app?

            // Fix categories not showing for pulled apps
            if let genre = Preferences.genres.first(where: { $0.category == "ios" && $0.id == genreId }) {
                category = Category(name: genre.name, id: genre.id)
            }
            seller = pname
            publisher = "© " + pname
        }

        // Screenshots

        if let data = screenshotsData.data(using: .utf8), let screenshotsParse = try? JSON(data: data) {
            var tmpScreens = [Screenshot]()
            for i in 0..<screenshotsParse["iphone"].count {
                tmpScreens.append(Screenshot(
                    src: screenshotsParse["iphone"][i]["src"].stringValue,
                    class_: guessScreenshotOrientation(from: screenshotsParse["iphone"][i]["src"].stringValue),
                    type: "iphone"
                ))
            }; screenshotsIphone = tmpScreens

            var tmpScreensIpad = [Screenshot]()
            for i in 0..<screenshotsParse["ipad"].count {
                tmpScreensIpad.append(Screenshot(
                    src: screenshotsParse["ipad"][i]["src"].stringValue,
                    class_: guessScreenshotOrientation(from: screenshotsParse["ipad"][i]["src"].stringValue),
                    type: "ipad"
                ))
            }; screenshotsIpad = tmpScreensIpad
        }
    }

    // Detect screenshot orientation from URL string
    private func guessScreenshotOrientation(from absoluteUrl: String) -> String {
        guard let ending = absoluteUrl.components(separatedBy: "/").last else { return  "portrait" }
        if ending.contains("bb."), let endingFilename = ending.components(separatedBy: "bb.").first {
            // e.g https://is4-ssl.mzstatic.com/image/.../source/406x228bb.jpg
            let size = endingFilename.components(separatedBy: "x")
            guard let width = Int(size[0]), let height = Int(size[1]) else { return "portrait" }
            if width == height {
                return knownLandscapeScreenshots.contains(absoluteUrl) ? "landscape" : "portrait"
            } else if width == 406 && height == 722 {
                return "landscape"
            }
            return width > height ? "landscape" : "portrait"
        } else if let endingFilename = ending.components(separatedBy: ".").first {
            // e.g. http://a1.mzstatic.com/us/r30/Purple2/.../screen568x568.jpeg
            guard endingFilename.contains("screen") else {
                // e.g. https://static.appdb.to/images/ios-1900000044-ipad-0.png
                return knownLandscapeScreenshots.contains(absoluteUrl) ? "landscape" : "portrait"
            }
            guard let size = endingFilename.components(separatedBy: "screen").last?.components(separatedBy: "x") else { return "portrait" }
            guard let width = Int(size[0]), let height = Int(size[1]) else { return "portrait" }
            if width == height {
                return knownLandscapeScreenshots.contains(absoluteUrl) ? "landscape" : "portrait"
            } else if width == 520 && height == 924 {
                return "landscape"
            }
            return width > height ? "landscape" : "portrait"
        } else {
            debugLog("WARNING: New filename convention detected! Please take a look: \(absoluteUrl)")
            return "portrait"
        }
    }
}
