//
//  Initializers.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import RealmSwift

//Utils
let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad

struct Global {
    
    // Sets Bool is first launch
    static func setFirstLaunch() {
        let realm = try! Realm()
        if let pref = realm.objects(Preferences.self).first {
            try! realm.write { pref.isFirstLaunch = false }
        } else {
            let pref = Preferences()
            pref.isFirstLaunch = true
            try! realm.write { realm.add(pref) }
        }
    }
    
    static var firstLaunch : Bool {
        let realm = try! Realm()
        return realm.objects(Preferences.self).first!.isFirstLaunch
    }
}

struct Filters {
    
    static let featured = AspectScaledToFillSizeWithRoundedCornersFilter(
        size: CGSize(width: Featured.size.itemWidth.value, height: Featured.size.itemWidth.value),
        radius: cornerRadius(fromWidth: Featured.size.itemWidth.value)
    )
    
    static let categories = AspectScaledToFillSizeWithRoundedCornersFilter(
        size: CGSize(width: 30, height: 30),
        radius: cornerRadius(fromWidth: 30)
    )
    
}
