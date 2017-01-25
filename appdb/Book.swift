//
//  Book.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
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
    
    //General
    dynamic var categoryId = ""
    dynamic var printLenght = ""
    dynamic var published = ""
    dynamic var author = ""
    
    //Text Cells
    dynamic var description_ = ""
    
    //Ratings
    dynamic var numberOfRating = ""
    dynamic var numberOfStars : Double = 0.0
    
    //Information
    dynamic var updated = ""
    dynamic var price = ""
    dynamic var requirements = ""
    dynamic var language = ""
    
    //Related
    dynamic var artistId = ""
    
    //Copyright
    dynamic var publisher = ""
    
    //Arrays
    var relatedBooks = List<RelatedApp>()
}

extension Book : Mappable {
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

        let itunesParse : JSON = JSON(data: lastParseItunes.data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        lastParseItunes.removeAll()
        
        // Information
        printLenght = itunesParse["printlength"].stringValue
        publisher = itunesParse["seller"].stringValue
        requirements = itunesParse["requirements"].stringValue
        published = itunesParse["published"].stringValue
        language = itunesParse["languages"].stringValue
        
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
        
        //Related Books
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
        }; relatedBooks = tmpRelated; tmpRelated.removeAll()

    }
}
