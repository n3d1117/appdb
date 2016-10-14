//
//  App.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import RealmSwift

class App : Item {
    
    //General
    dynamic var category = ""
    dynamic var seller = ""
    
    //Text cells
    dynamic var description_ = ""
    dynamic var whatsnew = ""
    
    //Information
    dynamic var bundleId = ""
    dynamic var published = ""
    dynamic var version = ""
    dynamic var size = ""
    dynamic var price = ""
    dynamic var rated = ""
    dynamic var compatibility = ""
    dynamic var appleWatch = ""
    dynamic var languages = ""
    
    //Support links
    dynamic var website = ""
    dynamic var support = ""
    
    //Ratings
    dynamic var numberOfRating = ""
    dynamic var numberOfStars : Double = 0.0
    
    //Dev apps
    dynamic var artistid = ""
    
    //Copyright notice
    dynamic var publisher = ""
    
    //Arrays
    let screenshots = List<Screenshot>()
    let screenshotsIpad = List<Screenshot>()
    let related = List<RelatedApp>()
    let versions = List<Version>()
    
    //Screenshots count
    var countPortrait : Int { return screenshots.filter{$0.class_=="portrait"}.count }
    var countLandscape : Int { return screenshots.filter{$0.class_=="landscape"}.count }
    var countPortraitIpad : Int { return screenshotsIpad.filter{$0.class_=="portrait"}.count }
    var countLandscapeIpad : Int { return screenshotsIpad.filter{$0.class_=="landscape"}.count }

}
