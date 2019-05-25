//
//  Preferences.swift
//  appdb
//
//  Created by ned on 27/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation

// Non sensitive data can be stored in UserDefaults
extension Defaults.Keys {
    static let theme = Key<Int>("theme", default: 0)
    static let didSpecifyPreferredLanguage = Key<Bool>("didSpecifyPreferredLanguage", default: false)
    static let appsync = Key<Bool>("appsync", default: false)
    static let ignoreCompatibility = Key<Bool>("ignoreCompatibility", default: false)
    static let askForInstallationOptions = Key<Bool>("askForInstallationOptions", default: false)
    static let showBadgeForUpdates = Key<Bool>("showBadgeForUpdates", default: true)
    static let ignoredUpdateableApps = Key<[IgnoredApp]>("ignoredUpdateableApps", default: [])
    static let genres = Key<[Genre]>("genres", default: [])
}

// Sensitive data is stored in Keychain
enum SecureKeys: String, CaseIterable {
    case token
    case linkCode
    case pro
    case proDisabled
    case proUntil
    case proRevoked
    case proRevokedOn
}

struct Preferences {

    // Sensitive data
    
    static var deviceIsLinked: Bool {
        return !(KeychainWrapper.standard.string(forKey: SecureKeys.token.rawValue) ?? "").isEmpty
    }

    static var pro: Bool {
        return KeychainWrapper.standard.bool(forKey: SecureKeys.pro.rawValue) ?? false
    }
    
    static var proUntil: String {
        return KeychainWrapper.standard.string(forKey: SecureKeys.proUntil.rawValue) ?? ""
    }
    
    static var proDisabled: Bool {
        return KeychainWrapper.standard.bool(forKey: SecureKeys.proDisabled.rawValue) ?? false
    }
    
    static var proRevoked: Bool {
        return KeychainWrapper.standard.bool(forKey: SecureKeys.proRevoked.rawValue) ?? false
    }
    
    static var proRevokedOn: String {
        return KeychainWrapper.standard.string(forKey: SecureKeys.proRevokedOn.rawValue) ?? ""
    }
    
    static var linkCode: String {
        return KeychainWrapper.standard.string(forKey: SecureKeys.linkCode.rawValue) ?? ""
    }
    
    static var linkToken: String {
        return KeychainWrapper.standard.string(forKey: SecureKeys.token.rawValue) ?? ""
    }
    
    // Non sensitive data
    
    static var didSpecifyPreferredLanguage: Bool {
        return defaults[.didSpecifyPreferredLanguage]
    }
    
    static var appsync: Bool {
        return defaults[.appsync]
    }
    
    static var ignoresCompatibility: Bool {
        return defaults[.ignoreCompatibility]
    }
    
    static var askForInstallationOptions: Bool {
        return defaults[.askForInstallationOptions]
    }
    
    static var showBadgeForUpdates: Bool {
        return defaults[.showBadgeForUpdates]
    }
    
    static var theme: Int {
        return defaults[.theme]
    }
    
    static var ignoredUpdateableApps: [IgnoredApp] {
        return defaults[.ignoredUpdateableApps]
    }
    
    static var genres: [Genre] {
        return defaults[.genres]
    }
}

extension Preferences {
    
    // Set value
    
    static func set(_ key: Defaults.Key<Bool>, to: Bool) {
        defaults[key] = to
    }
    
    static func set(_ key: Defaults.Key<Int>, to: Int) {
        defaults[key] = to
    }
    
    // Set secure value
    
    static func set(_ key: SecureKeys, to: Bool) {
        KeychainWrapper.standard.set(to, forKey: key.rawValue)
    }
    
    static func set(_ key: SecureKeys, to: String) {
        KeychainWrapper.standard.set(to, forKey: key.rawValue)
    }
    
    // Remove all

    static func removeKeysOnDeauthorization() {
        
        // Remove secure keys
        for key in SecureKeys.allCases {
            KeychainWrapper.standard.removeObject(forKey: key.rawValue)
        }
        
        // Remove normal keys
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.appsync.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.askForInstallationOptions.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.ignoreCompatibility.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.showBadgeForUpdates.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.ignoredUpdateableApps.name)
    }
}

extension Preferences {
    
    // Append / Remove value to IgnoredApp array
    
    static func append(_ key: Defaults.Key<[IgnoredApp]>, element: IgnoredApp) {
        defaults[key].append(element)
    }
    
    static func remove(_ key: Defaults.Key<[IgnoredApp]>, at index: Int) {
        defaults[key].remove(at: index)
    }
    
    // Append / Remove value to Genres array
    
    static func append(_ key: Defaults.Key<[Genre]>, element: Genre) {
        defaults[key].append(element)
    }
    
    static func remove(_ key: Defaults.Key<[Genre]>, at index: Int) {
        defaults[key].remove(at: index)
    }
}
