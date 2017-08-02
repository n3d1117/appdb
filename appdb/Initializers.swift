//
//  Initializers.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit
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
    
    // Returns true if it's first launch
    static var firstLaunch: Bool {
        let realm = try! Realm()
        if let pref = realm.objects(Preferences.self).first { return pref.isFirstLaunch }
        return false
    }
    
    // Returns App Version
    static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "~"
    
    // Utils
    static let bulletPoint = " • "
    static let tilde = "~"
    
    // Global sizes used throughout the app
    enum size {
        case spacing      // The spacing between items
        case margin       // Left margin
        case itemWidth    // The width of the items in the collectionView
        case heightIos    // Height of collectionView for ios (add 40 for height of cell)
        case heightBooks  // Height of collectionView for books
        
        var value: CGFloat {
            switch self {
            case .spacing: return (25~~15)
            case .margin: return (22~~15)
            case .itemWidth: return (83~~73)
            case .heightIos: return (150~~135)
            case .heightBooks: return (190~~180)
            }
        }
    }
    
    // Global collection view item sizes
    static let sizeIos: CGSize = CGSize(width: Global.size.itemWidth.value, height: Global.size.heightIos.value)
    static let sizeBooks: CGSize = CGSize(width: Global.size.itemWidth.value, height: Global.size.heightBooks.value)
    
    // Common corner radius for ios app icons
    static func cornerRadius(from width: CGFloat) -> CGFloat { return (width / 4.2) /* around 23% */ }
    
    // Returns appropriate ios app icon filter based on width
    static func getFilter(from width: CGFloat) -> CompositeImageFilter {
        return AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: Global.cornerRadius(from: width))
    }
}
