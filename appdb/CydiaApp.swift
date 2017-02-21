//
//  CydiaApp.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyJSON

class CydiaApp: Object, Meta {
    
    convenience required init?(map: Map) { self.init() }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    static func type() -> ItemType {
        return .cydia
    }
    
    var screenshots: String = ""
    
    dynamic var name = ""
    dynamic var id = ""
    dynamic var image = ""
    
    //General
    dynamic var categoryId = ""
    dynamic var developer = ""
    
    //Text cells
    dynamic var description_ = ""
    dynamic var whatsnew = ""
    
    //Information
    dynamic var bundleId = ""
    dynamic var version = ""
    dynamic var price = ""
    dynamic var updated = ""
    
    //Tweaked
    dynamic var originalTrackid = ""
    dynamic var originalSection = ""
    dynamic var isTweaked = false
    
    //Screenshots
    var screenshotsIphone = List<Screenshot>()
    var screenshotsIpad = List<Screenshot>()
    
    // Screenshots count
    var countPortraitIphone = 0
    var countLandscapeIphone = 0
    var countPortraitIpad = 0
    var countLandscapeIpad = 0
    
}

extension CydiaApp: Mappable {
    func mapping(map: Map) {
        
        name                    <- map["name"]
        id                      <- map["id"]
        image                   <- map["image"]
        bundleId                <- map["bundle_id"]
        developer               <- map["pname"]
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
        if developer.hasSuffix(" ") { developer = String(developer.characters.dropLast()) }
        
        let screenshotsParse = JSON(data: screenshots.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        // Screenshots
        let tmpScreens = List<Screenshot>()
        for i in 0..<screenshotsParse["iphone"].count {
            tmpScreens.append(Screenshot(
                src: screenshotsParse["iphone"][i]["src"].stringValue,
                class_: screenshotsParse["iphone"][i]["class"].stringValue
            ))
        }; screenshotsIphone = tmpScreens
        
        let tmpScreensIpad = List<Screenshot>()
        for i in 0..<screenshotsParse["ipad"].count {
            tmpScreensIpad.append(Screenshot(
                src: screenshotsParse["ipad"][i]["src"].stringValue,
                class_: screenshotsParse["ipad"][i]["class"].stringValue
            ))
        }; screenshotsIpad = tmpScreensIpad
        
        countPortraitIphone = screenshotsIphone.filter{$0.class_=="portrait"}.count
        countLandscapeIphone = screenshotsIphone.filter{$0.class_=="landscape"}.count
        countPortraitIpad = screenshotsIpad.filter{$0.class_=="portrait"}.count
        countLandscapeIpad = screenshotsIpad.filter{$0.class_=="landscape"}.count
        
    }
}
