//
//  CydiaApp.swift
//  appdb
//
//  Created by ned on 12/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import RealmSwift

class CydiaApp: Item {
    
    //General
    dynamic var category = ""
    dynamic var developer = ""
    
    //Text cells
    dynamic var description_ = ""
    dynamic var whatsnew = ""
    
    //Information
    dynamic var version = ""
    dynamic var added = ""
    dynamic var bundleId = ""
    
    //Tweaked
    dynamic var originalTrackid = ""
    dynamic var originalSection = ""
    var isTweaked : Bool { return originalTrackid != "0" }
    
    //Arrays
    let versions = List<Version>()
    let screenshots = List<Screenshot>()
    let screenshotsIpad = List<Screenshot>()
    
    //Screenshot counts
    var countPortrait : Int { return screenshots.filter{$0.class_=="portrait"}.count }
    var countLandscape : Int { return screenshots.filter{$0.class_=="landscape"}.count }
    var countPortraitIpad : Int { return screenshotsIpad.filter{$0.class_=="portrait"}.count }
    var countLandscapeIpad : Int { return screenshotsIpad.filter{$0.class_=="landscape"}.count }
    
}
