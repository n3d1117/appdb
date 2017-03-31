//
//  App.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import ObjectMapper
import SwiftyJSON

class App: Object, Meta {
    
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
    var category: Category?
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
    dynamic var published = ""
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
    dynamic var numberOfStars: Double = 0.0
    
    // Screenshots
    var screenshotsIphone = List<Screenshot>()
    var screenshotsIpad = List<Screenshot>()
    
    // Related Apps
    var relatedApps = List<RelatedContent>()
    
    // Related Apps
    var reviews = List<Review>()

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
        artistId                <- map["artist_id"]
        description_            <- map["description"]
        whatsnew                <- map["whatsnew"]
        screenshots             <- map["screenshots"]
        lastParseItunes         <- map["last_parse_itunes"]
        website                 <- map["pwebsite"]
        support                 <- map["psupport"]
        
        let screenshotsParse = JSON(data: screenshots.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        let itunesParse = JSON(data: lastParseItunes.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        // Information
        seller = itunesParse["seller"].stringValue
        size = itunesParse["size"].stringValue
        publisher = itunesParse["publisher"].stringValue
        published = itunesParse["published"].stringValue
        rated = itunesParse["rating"]["text"].stringValue + " " + itunesParse["rating"]["description"].stringValue
        compatibility = itunesParse["requirements"].stringValue
        appleWatch = itunesParse["apple_watch"].stringValue == "0" ? "No".localized() : "Yes".localized()
        languages = itunesParse["languages"].stringValue
        category = Category(name: itunesParse["genre"]["name"].stringValue, id: itunesParse["genre"]["id"].stringValue)
        
        if languages.contains("Watch") { languages = "Unknown".localized() } /* dirty fix "Languages: Apple Watch: Yes" */
        if published.hasPrefix(" ") { published = String(published.characters.dropFirst()) }

        // Ratings
        if !itunesParse["ratings"]["current"].stringValue.isEmpty {
            
            //numberOfRating
            let array = itunesParse["ratings"]["current"].stringValue.components(separatedBy: ", ")
            let array2 = "\(array[1])".components(separatedBy: " ")
            if let tmpNumber = Int(array2[0]) {
                let num: NSNumber = NSNumber(value: tmpNumber)
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
        
        //Related Apps
        let tmpRelated = List<RelatedContent>()
        for i in 0..<itunesParse["relatedapps"].count {
            let item = itunesParse["relatedapps"][i]
            if !item["type"].stringValue.isEmpty, !item["trackid"].isEmpty, !item["artist"]["name"].stringValue.isEmpty {
                tmpRelated.append(RelatedContent(
                    icon: item["image"].stringValue,
                    id: item["trackid"].stringValue,
                    name: item["name"].stringValue,
                    artist: item["artist"]["name"].stringValue
                ))
            }
        }
        
        //Also Bought
        for i in 0..<itunesParse["alsobought"].count {
            let item = itunesParse["alsobought"][i]
            if !item["type"].stringValue.isEmpty, !item["trackid"].stringValue.isEmpty, !item["artist"]["name"].stringValue.isEmpty {
                tmpRelated.append(RelatedContent(
                    icon: item["image"].stringValue,
                    id: item["trackid"].stringValue,
                    name: item["name"].stringValue,
                    artist: item["artist"]["name"].stringValue
                ))
            }
        }; relatedApps = tmpRelated
        
        // Reviews
        let tmpReviews = List<Review>()
        for i in 0..<itunesParse["reviews"].count {
            let item = itunesParse["reviews"][i]
            tmpReviews.append(Review(
                author: item["author"].stringValue,
                text: item["text"].stringValue,
                title: item["title"].stringValue,
                rating: item["rating"].doubleValue
            ))
        }; reviews = tmpReviews
            
    }
}
