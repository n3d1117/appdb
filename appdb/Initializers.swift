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
            if pref.isFirstLaunch { try! realm.write { pref.isFirstLaunch = false } }
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
    
    static func getFilter(from width: CGFloat) -> CompositeImageFilter {
        return AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: cornerRadius(fromWidth: width))
    }
    
}
