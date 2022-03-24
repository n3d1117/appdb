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
    static let theme = Key<Int>("theme", default: Global.isDarkSystemAppearance ? 1 : 0)
    static let didSpecifyPreferredLanguage = Key<Bool>("didSpecifyPreferredLanguage", default: false)
    static let appsync = Key<Bool>("appsync", default: false)
    static let ignoreCompatibility = Key<Bool>("ignoreCompatibility", default: false)
    static let askForInstallationOptions = Key<Bool>("askForInstallationOptions", default: false)
    static let showBadgeForUpdates = Key<Bool>("showBadgeForUpdates", default: true)
    static let changeBundleBeforeUpload = Key<Bool>("changeBundleBeforeUpload", default: false)
    static let ignoredUpdateableApps = Key<[IgnoredApp]>("ignoredUpdateableApps", default: [])
    static let resumeQueuedApps = Key<[RequestedApp]>("resumeQueuedApps", default: [])
    static let genres = Key<[Genre]>("genres", default: [])
    static let followSystemAppearance = Key<Bool>("followSystemAppearance", default: true)
    static let shouldSwitchToDarkerTheme = Key<Bool>("shouldSwitchToDarkerTheme", default: false)
    static let deviceName = Key<String>("deviceName", default: "")
    static let deviceVersion = Key<String>("deviceVersion", default: "")
    static let enableIapPatch = Key<Bool>("enableIapPatch", default: false)
    static let disableRevocationChecks = Key<Bool>("disableRevocationChecks", default: false)
    static let forceDisablePRO = Key<Bool>("forceDisablePRO", default: false)
    static let enableTrainer = Key<Bool>("enableTrainer", default: false)
    static let signingIdentityType = Key<String>("signingIdentityType", default: "auto")
    static let optedOutFromEmails = Key<Bool>("optedOutFromEmails", default: false)
    static let removePlugins = Key<Bool>("removePlugins", default: false)
    static let enablePushNotifications = Key<Bool>("enablePush", default: false)
    static let duplicateApp = Key<Bool>("duplicateApp", default: true)
}

// Sensitive data is stored in Keychain
enum SecureKeys: String, CaseIterable {
    case token
    case linkCode
    case pro
    case proUntil
    case proRevoked
    case proRevokedOn
    case usesCustomDeveloperIdentity
}

enum Preferences {

    // Sensitive data

    static var deviceIsLinked: Bool {
        !(KeychainWrapper.standard.string(forKey: SecureKeys.token.rawValue) ?? "").isEmpty
    }

    static var pro: Bool {
        KeychainWrapper.standard.bool(forKey: SecureKeys.pro.rawValue) ?? false
    }

    static var proUntil: String {
        KeychainWrapper.standard.string(forKey: SecureKeys.proUntil.rawValue) ?? ""
    }

    static var proRevoked: Bool {
        KeychainWrapper.standard.bool(forKey: SecureKeys.proRevoked.rawValue) ?? false
    }

    static var proRevokedOn: String {
        KeychainWrapper.standard.string(forKey: SecureKeys.proRevokedOn.rawValue) ?? ""
    }

    static var usesCustomDeveloperIdentity: Bool {
        KeychainWrapper.standard.bool(forKey: SecureKeys.usesCustomDeveloperIdentity.rawValue) ?? false
    }

    static var linkCode: String {
        KeychainWrapper.standard.string(forKey: SecureKeys.linkCode.rawValue) ?? ""
    }

    static var linkToken: String {
        KeychainWrapper.standard.string(forKey: SecureKeys.token.rawValue) ?? ""
    }

    // Non sensitive data

    static var didSpecifyPreferredLanguage: Bool {
        defaults[.didSpecifyPreferredLanguage]
    }

    static var appsync: Bool {
        defaults[.appsync]
    }

    static var ignoresCompatibility: Bool {
        defaults[.ignoreCompatibility]
    }

    static var askForInstallationOptions: Bool {
        defaults[.askForInstallationOptions]
    }

    static var showBadgeForUpdates: Bool {
        defaults[.showBadgeForUpdates]
    }

    static var changeBundleBeforeUpload: Bool {
        defaults[.changeBundleBeforeUpload]
    }

    static var theme: Int {
        defaults[.theme]
    }

    static var ignoredUpdateableApps: [IgnoredApp] {
        defaults[.ignoredUpdateableApps]
    }

    static var resumeQueuedApps: [RequestedApp] {
        defaults[.resumeQueuedApps]
    }

    static var genres: [Genre] {
        defaults[.genres]
    }

    static var followSystemAppearance: Bool {
        defaults[.followSystemAppearance]
    }

    static var shouldSwitchToDarkerTheme: Bool {
        defaults[.shouldSwitchToDarkerTheme]
    }

    static var deviceName: String {
        defaults[.deviceName]
    }

    static var deviceVersion: String {
        defaults[.deviceVersion]
    }

    static var enableIapPatch: Bool {
        defaults[.enableIapPatch]
    }

    static var disableRevocationChecks: Bool {
        defaults[.disableRevocationChecks]
    }

    static var forceDisablePRO: Bool {
        defaults[.forceDisablePRO]
    }

    static var enableTrainer: Bool {
        defaults[.enableTrainer]
    }

    static var signingIdentityType: String {
        defaults[.signingIdentityType]
    }

    static var optedOutFromEmails: Bool {
        defaults[.optedOutFromEmails]
    }

    static var removePlugins: Bool {
        defaults[.removePlugins]
    }

    static var enablePushNotifications: Bool {
        defaults[.enablePushNotifications]
    }

    static var duplicateApp: Bool {
        defaults[.duplicateApp]
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

    static func set(_ key: Defaults.Key<String>, to: String) {
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
        removeKeychainData()

        // Remove normal keys
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.appsync.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.askForInstallationOptions.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.ignoreCompatibility.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.showBadgeForUpdates.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.changeBundleBeforeUpload.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.ignoredUpdateableApps.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.resumeQueuedApps.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.deviceName.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.deviceVersion.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.enableIapPatch.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.disableRevocationChecks.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.forceDisablePRO.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.enableTrainer.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.signingIdentityType.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.optedOutFromEmails.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.removePlugins.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.enablePushNotifications.name)
        UserDefaults.standard.removeObject(forKey: Defaults.Keys.duplicateApp.name)
    }

    // Remove secure keys
    static func removeKeychainData() {
        for key in SecureKeys.allCases {
            KeychainWrapper.standard.removeObject(forKey: key.rawValue)
        }
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

    // Append / Remove value to RequestedApp array

    static func append(_ key: Defaults.Key<[RequestedApp]>, element: RequestedApp) {
        defaults[key].append(element)
    }

    static func removeAll(_ key: Defaults.Key<[RequestedApp]>) {
        defaults[key].removeAll()
    }

    // Append / Remove value to Genres array

    static func append(_ key: Defaults.Key<[Genre]>, element: Genre) {
        defaults[key].append(element)
    }

    static func remove(_ key: Defaults.Key<[Genre]>, at index: Int) {
        defaults[key].remove(at: index)
    }
}
