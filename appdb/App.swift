//
//  App.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//


import UIKit
import RealmSwift
import SwiftyJSON
import ObjectMapper

class App: Object, Meta {
    
    convenience required init?(map: Map) { self.init() }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    static func type() -> ItemType {
        return .ios
    }
    
    @objc dynamic var name = ""
    @objc dynamic var id = ""
    @objc dynamic var image = ""

    // iTunes data
    var lastParseItunes = ""
    var screenshots = ""
    
    // General
    var category: Category?
    @objc dynamic var seller = ""
    
    // Text cells
    @objc dynamic var description_ = ""
    @objc dynamic var whatsnew = ""
    
    // Dev apps
    @objc dynamic var artistId = ""
    @objc dynamic var genreId = ""
    
    // Copyright notice
    @objc dynamic var publisher = ""
    @objc dynamic var pname = ""
    
    // Information
    @objc dynamic var bundleId = ""
    @objc dynamic var updated = ""
    @objc dynamic var published = ""
    @objc dynamic var version = ""
    @objc dynamic var price = ""
    @objc dynamic var size = ""
    @objc dynamic var rated = ""
    @objc dynamic var compatibility = ""
    @objc dynamic var languages = ""
    
    // Support links
    @objc dynamic var website = ""
    @objc dynamic var support = ""
    
    // Ratings
    @objc dynamic var numberOfRating = ""
    @objc dynamic var numberOfStars: Double = 0.0
    
    // Screenshots
    var screenshotsIphone = List<Screenshot>()
    var screenshotsIpad = List<Screenshot>()

}

extension App: Mappable {
    
    func mapping(map: Map) {

        name                    <- map["name"]
        id                      <- map["id"]
        image                   <- map["image"]
        bundleId                <- map["bundle_id"]
        version                 <- map["version"]
        price                   <- map["price"]
        updated                 <- map["added"]
        genreId                 <- map["genre_id"]
        artistId                <- map["artist_id"]
        description_            <- map["description"]
        whatsnew                <- map["whatsnew"]
        screenshots             <- map["screenshots"]
        lastParseItunes         <- map["last_parse_itunes"]
        website                 <- map["pwebsite"]
        support                 <- map["psupport"]
        pname                   <- map["pname"]
        
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
            let realm = try! Realm()
            if let genre = realm.objects(Genre.self).filter("category = %@ AND id = %@", "ios", genreId).first {
                category = Category(name: genre.name, id: genre.id)
            }
            seller = pname
            publisher = "© " + pname
        }
        
        // Screenshots
        
        if let data = screenshots.data(using: .utf8), let screenshotsParse = try? JSON(data: data) {
            
            let tmpScreens = List<Screenshot>()
            for i in 0..<screenshotsParse["iphone"].count {
                tmpScreens.append(Screenshot(
                    src: screenshotsParse["iphone"][i]["src"].stringValue,
                    class_: guessScreenshotOrientation(from: screenshotsParse["iphone"][i]["src"].stringValue),
                    type: "iphone"
                ))
            }; screenshotsIphone = tmpScreens
            
            let tmpScreensIpad = List<Screenshot>()
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
    fileprivate func guessScreenshotOrientation(from absoluteUrl: String) -> String {
        guard let ending = absoluteUrl.components(separatedBy: "/").last else { return  "portrait" }
        if ending.contains("bb."), let endingFilename = ending.components(separatedBy: "bb.").first {
            // e.g https://is4-ssl.mzstatic.com/image/.../source/406x228bb.jpg
            let size = endingFilename.components(separatedBy: "x")
            guard let width = Int(size[0]), let height = Int(size[1]) else { return "portrait" }
            return width > height ? "landscape" : "portrait"
        } else if let endingFilename = ending.components(separatedBy: ".").first {
            // e.g. http://a1.mzstatic.com/us/r30/Purple2/.../screen568x568.jpeg
            guard let size = endingFilename.components(separatedBy: "screen").last?.components(separatedBy: "x") else { return "portrait" }
            guard let width = Int(size[0]), let height = Int(size[1]) else { return "portrait" }
            return width > height ? "landscape" : "portrait"
        } else {
            print("WARNING: New filename convention detected! Please take a look")
            return "portrait"
        }
    }
}
