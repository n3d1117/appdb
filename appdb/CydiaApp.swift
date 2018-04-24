//
//  CydiaApp.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//


import RealmSwift
import SwiftyJSON
import ObjectMapper

class CydiaApp: Object, Meta {
    
    convenience required init?(map: Map) { self.init() }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    static func type() -> ItemType {
        return .cydia
    }
    
    var screenshots: String = ""
    
    @objc dynamic var name = ""
    @objc dynamic var id = ""
    @objc dynamic var image = ""
    
    // General
    @objc dynamic var categoryId = ""
    @objc dynamic var developer = ""
    @objc dynamic var developerId = ""
    
    // Text
    @objc dynamic var description_ = ""
    @objc dynamic var whatsnew = ""
    
    // Information
    @objc dynamic var bundleId = ""
    @objc dynamic var version = ""
    @objc dynamic var price = ""
    @objc dynamic var updated = ""
    
    // Tweaked
    @objc dynamic var originalTrackid = ""
    @objc dynamic var originalSection = ""
    @objc dynamic var isTweaked = false
    
    // Screenshots
    var screenshotsIphone = List<Screenshot>()
    var screenshotsIpad = List<Screenshot>()
    
}

extension CydiaApp: Mappable {
    func mapping(map: Map) {
        
        name                    <- map["name"]
        id                      <- map["id"]
        image                   <- map["image"]
        bundleId                <- map["bundle_id"]
        developer               <- map["pname"]
        developerId             <- map["artist_id"]
        version                 <- map["version"]
        price                   <- map["price"]
        categoryId              <- map["genre_id"]
        updated                 <- map["added"]
        description_            <- map["description"]
        whatsnew                <- map["whatsnew"]
        originalTrackid         <- map["original_trackid"]
        originalSection         <- map["original_section"]
        screenshots             <- map["screenshots"]

        isTweaked = originalTrackid != "0"
        if developer.hasSuffix(" ") { developer = String(developer.dropLast()) }
        
        do {
            let screenshotsParse = try JSON(data: screenshots.data(using: .utf8, allowLossyConversion: false)!)
        
            // Screenshots
            let tmpScreens = List<Screenshot>()
            for i in 0..<screenshotsParse["iphone"].count {
                tmpScreens.append(Screenshot(
                    src: screenshotsParse["iphone"][i]["src"].stringValue,
                    class_: screenshotsParse["iphone"][i]["class"].stringValue,
                    type: "iphone"
                ))
            }; screenshotsIphone = tmpScreens
        
            let tmpScreensIpad = List<Screenshot>()
            for i in 0..<screenshotsParse["ipad"].count {
                tmpScreensIpad.append(Screenshot(
                    src: screenshotsParse["ipad"][i]["src"].stringValue,
                    class_: screenshotsParse["ipad"][i]["class"].stringValue,
                    type: "ipad"
                ))
            }; screenshotsIpad = tmpScreensIpad
            
        } catch {
            // ...
        }
        
    }
}
