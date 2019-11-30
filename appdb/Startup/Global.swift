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

enum Global {

    static let mainSite: String = "https://appdb.to/"
    static let githubSite: String = "https://github.com/n3d1117/appdb"
    static let email: String = "appdb.ned@gmail.com"
    static let telegramUsername: String = "ne_do"

    // Homescreen shortcut items
    enum ShortcutItem: String {

        case search, wishes, updates, news

        static func createItems(for items: [ShortcutItem]) -> [UIApplicationShortcutItem] {
            return items.map { createItem(for: $0) }
        }

        static func createItem(for item: ShortcutItem) -> UIApplicationShortcutItem {
            return UIApplicationShortcutItem(type: item.rawValue, localizedTitle: item.title, localizedSubtitle: nil, icon: item.icon, userInfo: nil)
        }

        var icon: UIApplicationShortcutIcon {
            switch self {
            case .search:
                return UIApplicationShortcutIcon(type: .search)
            case .wishes:
                if #available(iOS 13.0, *) {
                    return UIApplicationShortcutIcon(systemImageName: "gift")
                } else  if #available(iOS 9.1, *) {
                    return UIApplicationShortcutIcon(type: .love)
                } else {
                    return UIApplicationShortcutIcon(type: .add)
                }
            case .updates:
                if #available(iOS 13.0, *) {
                    return UIApplicationShortcutIcon(systemImageName: "square.and.arrow.down")
                } else  if #available(iOS 9.1, *) {
                    return UIApplicationShortcutIcon(type: .update)
                } else {
                    return UIApplicationShortcutIcon(systemImageName: "updates")
                }
            case .news:
                if #available(iOS 13.0, *) {
                    return UIApplicationShortcutIcon(systemImageName: "bubble.left")
                } else  if #available(iOS 9.1, *) {
                    return UIApplicationShortcutIcon(type: .message)
                } else {
                    return UIApplicationShortcutIcon(type: .compose)
                }
            }
        }

        var title: String {
            switch self {
            case .search: return "Search".localized()
            case .wishes: return "Wishes".localized()
            case .updates: return "Updates".localized()
            case .news: return "News".localized()
            }
        }

        var resolvedUrl: URL {
            switch self {
            case .search: return URL(string: "appdb-ios://?tab=search")!
            case .wishes: return URL(string: "appdb-ios://?tab=wishes")!
            case .updates: return URL(string: "appdb-ios://?tab=updates")!
            case .news: return URL(string: "appdb-ios://?tab=news")!
            }
        }
    }

    static let isIpad: Bool = UIDevice.current.userInterfaceIdiom == .pad

    static var hasNotch: Bool {
        if #available(iOS 11, *) {
            guard let window = UIApplication.shared.keyWindow else { return false }
            let insets = window.safeAreaInsets
            return insets.top > 0 || insets.bottom > 0
        } else {
            return false
        }
    }

    static var isDarkSystemAppearance: Bool {
        if #available(iOS 13.0, *) {
            return UIScreen.main.traitCollection.userInterfaceStyle == .dark
        } else {
            return false
        }
    }

    static func refreshAppearanceForCurrentTheme() {
        if #available(iOS 13.0, *) {
            var style: UIUserInterfaceStyle = Themes.current == .light ? .light : .dark
            if Preferences.followSystemAppearance { style = .unspecified }
            if UINavigationBar.appearance().overrideUserInterfaceStyle != style {
                UINavigationBar.appearance().overrideUserInterfaceStyle = style
                UITabBar.appearance().overrideUserInterfaceStyle = style
                UISegmentedControl.appearance().overrideUserInterfaceStyle = style
                UIToolbar.appearance().overrideUserInterfaceStyle = style
                UIView.appearance().overrideUserInterfaceStyle = style
                UIWindow.appearance().overrideUserInterfaceStyle = style
                UILabel.appearance().overrideUserInterfaceStyle = style
                UIButton.appearance().overrideUserInterfaceStyle = style
                UITableViewHeaderFooterView.appearance().overrideUserInterfaceStyle = style
            }
        }
    }

    // Returns App Version
    static let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? tilde

    // Utils
    static let bulletPoint = " • "
    static let tilde = "~"
    static let notMaxPriority = LayoutPriority(rawValue: UILayoutPriority.RawValue(999.0))

    // Global sizes used throughout the app
    enum Size {
        case spacing      // The spacing between items
        case margin       // Left margin
        case itemWidth    // The width of the items in the collectionView
        case heightIos    // Height of collectionView for ios (add 40 for height of cell)
        case heightBooks  // Height of collectionView for books

        var value: CGFloat {
            switch self {
            case .spacing: return (25 ~~ 15)
            case .margin: return (22 ~~ 15)
            case .itemWidth: return (83 ~~ 73)
            case .heightIos: return (150 ~~ 135)
            case .heightBooks: return (190 ~~ 180)
            }
        }
    }

    // Global collection view item sizes
    static let sizeIos = CGSize(width: Global.Size.itemWidth.value, height: Global.Size.heightIos.value)
    static let sizeBooks = CGSize(width: Global.Size.itemWidth.value, height: Global.Size.heightBooks.value)

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

    // Delete keychain data if first launch. Old data might still be there...
    static func deleteEventualKeychainData() {
        if !UserDefaults.standard.bool(forKey: "notFirstRun") {
            Preferences.removeKeychainData()
            UserDefaults.standard.set(true, forKey: "notFirstRun")
        }
    }
}
