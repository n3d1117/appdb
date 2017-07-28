//
//  Book.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class Book: Object, Meta {
    
    convenience required init?(map: Map) { self.init() }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    static func type() -> ItemType {
        return .books
    }
    
    // iTunes data
    var lastParseItunes = ""
    
    dynamic var name = ""
    dynamic var id = ""
    dynamic var image = ""
    
    // General
    dynamic var categoryId = ""
    dynamic var printLenght = ""
    dynamic var published = ""
    dynamic var author = ""
    
    // Text
    dynamic var description_ = ""
    
    // Ratings
    dynamic var numberOfRating = ""
    dynamic var numberOfStars: Double = 0.0
    
    // Information
    dynamic var updated = ""
    dynamic var price = ""
    dynamic var requirements = ""
    dynamic var language = ""
    
    // Artist ID
    dynamic var artistId = ""
    
    // Copyright
    dynamic var publisher = ""
    
    // Related Books
    var relatedBooks = List<RelatedContent>()
    
    // Related Apps
    var reviews = List<Review>()
}

extension Book: Mappable {
    func mapping(map: Map) {
        
        name                    <- map["name"]
        id                      <- map["id"]
        image                   <- map["image"]
        price                   <- map["price"]
        categoryId              <- map["genre_id"]
        author                  <- map["pname"]
        updated                 <- map["added"]
        description_            <- map["description"]
        artistId                <- map["artist_id"]
        lastParseItunes         <- map["last_parse_itunes"]

        let itunesParse: JSON = JSON(data: lastParseItunes.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        
        // Information
        printLenght = itunesParse["printlength"].stringValue
        publisher = itunesParse["seller"].stringValue
        requirements = itunesParse["requirements"].stringValue
        published = itunesParse["published"].stringValue
        language = itunesParse["languages"].stringValue
        
        while published.hasPrefix(" ") { published = String(published.characters.dropFirst()) }
        
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
        
        //Related Books
        let tmpRelated = List<RelatedContent>()
        for i in 0..<itunesParse["relatedapps"].count {
            let item = itunesParse["relatedapps"][i]
            if !item["type"].stringValue.isEmpty, !item["trackid"].stringValue.isEmpty, !item["artist"]["name"].stringValue.isEmpty {
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
        }; relatedBooks = tmpRelated
        
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
