//
//  App.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import SwiftyJSON

class App : Object, Meta {
    
    convenience required init?(map: Map) { self.init() }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    static func type() -> ItemType {
        return .ios
    }
    
    dynamic var name = ""
    dynamic var id = ""
    dynamic var image = ""

    // iTunes data
    var lastParseItunes = ""
    var screenshots = ""
    
    // General
    var category : Category?
    dynamic var seller = ""
    
    // Text cells
    dynamic var description_ = ""
    dynamic var whatsnew = ""
    
    // Dev apps
    dynamic var artistId = ""
    
    // Copyright notice
    dynamic var publisher = ""
    
    // Information
    dynamic var bundleId = ""
    dynamic var updated = ""
    dynamic var version = ""
    dynamic var price = ""
    dynamic var size = ""
    dynamic var rated = ""
    dynamic var compatibility = ""
    dynamic var appleWatch = ""
    dynamic var languages = ""
    
    // Support links
    dynamic var website = ""
    dynamic var support = ""
    
    // Ratings
    dynamic var numberOfRating = ""
    dynamic var numberOfStars : Double = 0.0
    
    // Screenshots
    var screenshotsIphone = List<Screenshot>()
    var screenshotsIpad = List<Screenshot>()
    
    // Related Apps
    var relatedApps = List<RelatedApp>()
    
    // Screenshots count
    var countPortraitIphone = 0
    var countLandscapeIphone = 0
    var countPortraitIpad = 0
    var countLandscapeIpad = 0

}

extension App : Mappable {
    
    func mapping(map: Map) {

        name                    <- map["name"]
        id                      <- map["id"]
        image                   <- map["image"]
        bundleId                <- map["bundle_id"]
        version                 <- map["version"]
        price                   <- map["price"]
        updated                 <- map["added"]
        artistId                <- map["artist_id"]
        description_            <- map["description"]
        whatsnew                <- map["whatsnew"]
        screenshots             <- map["screenshots"]
        lastParseItunes         <- map["last_parse_itunes"]
        publisher               <- map["pname"]
        website                 <- map["pwebsite"]
        support                 <- map["psupport"]
        
        autoreleasepool {
        
        let screenshotsParse = JSON(data: screenshots.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        let itunesParse : JSON = JSON(data: lastParseItunes.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        screenshots.removeAll(); lastParseItunes.removeAll()
        
        // Information
        seller = itunesParse["seller"].stringValue
        size = itunesParse["size"].stringValue
        rated = itunesParse["rating"]["text"].stringValue + " " + itunesParse["rating"]["description"].stringValue
        compatibility = itunesParse["requirements"].stringValue
        appleWatch = itunesParse["apple_watch"].stringValue == "0" ? "No" : "Yes"
        languages = itunesParse["languages"].stringValue
        category = Category(name: itunesParse["genre"]["name"].stringValue, id: itunesParse["genre"]["id"].stringValue)
        
        // Ratings
        if !itunesParse["ratings"]["current"].stringValue.isEmpty {
            
            //numberOfRating
            let array = itunesParse["ratings"]["current"].stringValue.components(separatedBy: ", ")
            let array2 = "\(array[1])".components(separatedBy: " ")
            if let tmpNumber = Int(array2[0]) {
                let num : NSNumber = NSNumber(value: tmpNumber)
                numberOfRating = "(" + NumberFormatter.localizedString(from: num, number: .decimal) + ")"
            }
            
            //numberOfStars
            let array3 = itunesParse["ratings"]["current"].stringValue.components(separatedBy: " ")
            if let tmpStars = Double(array3[0]) {
                numberOfStars = itunesParse["ratings"]["current"].stringValue.contains("half") ? tmpStars + 0.5 : tmpStars
            }
        }
        
        
        // Screenshots
        let tmpScreens = List<Screenshot>()
        for i in 0..<screenshotsParse["iphone"].count {
            tmpScreens.append(Screenshot(
                src: screenshotsParse["iphone"][i]["src"].stringValue,
                class_: screenshotsParse["iphone"][i]["class"].stringValue
            ))
        }; screenshotsIphone = tmpScreens; tmpScreens.removeAll()
        
        let tmpScreensIpad = List<Screenshot>()
        for i in 0..<screenshotsParse["ipad"].count {
            tmpScreensIpad.append(Screenshot(
                src: screenshotsParse["ipad"][i]["src"].stringValue,
                class_: screenshotsParse["ipad"][i]["class"].stringValue
            ))
        }; screenshotsIpad = tmpScreensIpad; tmpScreensIpad.removeAll();
        
        countPortraitIphone = screenshotsIphone.filter{$0.class_=="portrait"}.count
        countLandscapeIphone = screenshotsIphone.filter{$0.class_=="landscape"}.count
        countPortraitIpad = screenshotsIpad.filter{$0.class_=="portrait"}.count
        countLandscapeIpad = screenshotsIpad.filter{$0.class_=="landscape"}.count
        
        //Related Apps
        let tmpRelated = List<RelatedApp>()
        for i in 0..<itunesParse["relatedapps"].count {
            if !itunesParse["relatedapps"][i]["trackid"].stringValue.isEmpty && !itunesParse["relatedapps"][i]["artist"]["name"].stringValue.isEmpty {
                tmpRelated.append(RelatedApp(
                    icon: itunesParse["relatedapps"][i]["name"].stringValue,
                    id: itunesParse["relatedapps"][i]["trackid"].stringValue,
                    name: itunesParse["relatedapps"][i]["artist"]["name"].stringValue,
                    artist: itunesParse["relatedapps"][i]["image"].stringValue
                ))
            }
        }
        
        //Also Bought
        for i in 0..<itunesParse["alsobought"].count {
            if !itunesParse["alsobought"][i]["trackid"].stringValue.isEmpty && !itunesParse["alsobought"][i]["artist"]["name"].stringValue.isEmpty {
                tmpRelated.append(RelatedApp(
                    icon: itunesParse["alsobought"][i]["name"].stringValue,
                    id: itunesParse["alsobought"][i]["trackid"].stringValue,
                    name: itunesParse["alsobought"][i]["artist"]["name"].stringValue,
                    artist: itunesParse["alsobought"][i]["image"].stringValue
                ))
            }
        }; relatedApps = tmpRelated; tmpRelated.removeAll()
            
        }
    }
}
