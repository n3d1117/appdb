//
//  Book.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import RealmSwift

class Book: Item {
    
    //General
    dynamic var category = ""
    dynamic var printLenght = ""
    dynamic var published = ""
    dynamic var artist = ""
    
    //Text Cells
    dynamic var description_ = ""
    
    //Ratings
    dynamic var numberOfRating = ""
    dynamic var numberOfStars : Double = 0.0
    
    //Information
    dynamic var added = ""
    dynamic var price = ""
    dynamic var requirements = ""
    dynamic var language = ""
    
    //Related
    dynamic var artistid = ""
    
    //Copyright
    dynamic var publisher = ""
    
    //Arrays
    let related = List<RelatedApp>()
    let versions = List<Version>()

}
