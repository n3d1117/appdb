//
//  UpdateableApp.swift
//  appdb
//
//  Created by ned on 10/11/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import RealmSwift
import UIKit
import SwiftyJSON
import ObjectMapper

class IgnoredUpdateableApps: Object {
    let ignoredTrackids = List<String>()
}

class UpdateableApp: Object {
    
    convenience required init?(map: Map) { self.init() }
    
    override class func primaryKey() -> String? {
        return "trackid"
    }
    
    var itemType: ItemType = .ios

    @objc dynamic var versionOld = ""
    @objc dynamic var versionNew = ""
    @objc dynamic var alongsideId = ""
    @objc dynamic var trackid = ""
    @objc dynamic var image = ""
    @objc dynamic var updateable = false
    @objc dynamic var type = ""
    @objc dynamic var name = ""
    @objc dynamic var whatsnew = ""
    @objc dynamic var date = ""
    
    var isIgnored: Bool {
        let realm = try! Realm()
        guard let ignored = realm.objects(IgnoredUpdateableApps.self).first else { return false }
        return ignored.ignoredTrackids.contains(trackid)
    }
    
}

extension UpdateableApp: Mappable {
    
    func mapping(map: Map) {
        versionOld                    <- map["version_old"]
        versionNew                    <- map["version_new"]
        alongsideId                   <- map["alongside_id"]
        trackid                       <- map["trackid"]
        image                         <- map["image"]
        updateable                    <- map["updateable"]
        type                          <- map["type"]
        name                          <- map["name"]
        whatsnew                      <- map["whatsnew"]
        date                          <- map["added"]
        
        itemType = type == "ios" ? .ios : .cydia
    }
}
