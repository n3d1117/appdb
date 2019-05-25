//
//  Global.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography
import AlamofireImage
import Localize_Swift

// Utils

func debugLog(_ arg: Any) {
    #if DEBUG
        NSLog("** [LOG] \(arg)")
    #endif
}

struct Global {
    
    static let isIpad = UIDevice.current.userInterfaceIdiom == .pad
    
    static var hasNotch: Bool {
        if #available(iOS 11, *) {
            guard let window = UIApplication.shared.keyWindow else { return false }
            let insets = window.safeAreaInsets
            return insets.top > 0 || insets.bottom > 0
        } else {
            return false
        }
    }
    
    static let mainSite: String = "https://appdb.to/"
    
    // Returns App Version
    static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? tilde
    
    // Utils
    static let bulletPoint = " • "
    static let tilde = "~"
    static let notMaxPriority = LayoutPriority(rawValue: UILayoutPriority.RawValue(999.0))
    
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
    static func roundedFilter(from width: CGFloat) -> ImageFilter {
        return AspectScaledToFillSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: cornerRadius(from: width))
    }
    
    // Returns appropriate screenshot filter base on size and radius
    static func screenshotRoundedFilter(size: CGSize, radius: CGFloat) -> ImageFilter {
        return AspectScaledToFillSizeWithRoundedCornersFilter(size: size, radius: radius)
    }
    
    // Returns a random string with given length
    static func randomString(length: Int) -> String {
        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }
    
    // Returns a short localized string (e.g '15s ago') that represents the distance between input date and now
    static func formattedTimeFromNow(from startDate: Date) -> String {
        let calendar = Calendar.current
        let difference = calendar.dateComponents([.day, .hour, .minute, .second], from: startDate, to: Date())
        
        guard let s = difference.second, let m = difference.minute, let h = difference.hour, let d = difference.day else { return "" }
        
        let seconds = "%@s ago".localizedFormat(String(s)), minutes = "%@m ago".localizedFormat(String(m))
        let hours = "%@h ago".localizedFormat(String(h)), days = "%@d ago".localizedFormat(String(d))
        
        if d > 0 { return days }
        if h > 0 { return hours }
        if m > 0 { return minutes }
        if s > 0 { return seconds }
        
        return "now".localized()
    }
    
    // Human readable size from byte count
    static func humanReadableSize(bytes: Int64) -> String {
        return ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
    
    // Sets app language the same as device language, unless it's been previously changed from Settings
    static func restoreLanguage() {
        let defaultLanguage = Localize.defaultLanguage()
        if !Preferences.didSpecifyPreferredLanguage, defaultLanguage != Localize.currentLanguage() {
            Localize.setCurrentLanguage(defaultLanguage)
            UserDefaults.standard.set([defaultLanguage], forKey: "AppleLanguages")
        }
    }
    
}
