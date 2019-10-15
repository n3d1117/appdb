//
//  Settings+Sections.swift
//  appdb
//
//  Created by ned on 14/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Static
import UIKit
import Localize_Swift

extension Settings {

    // Device info string, e.g. "iPhone 6s (10.2)"
    var deviceInfoString: String {
        let device = UIDevice.current
        return device.deviceType.displayName + " (" + device.systemVersion + ")"
    }

    var forumSite: String {
        return "https://forum." + Global.mainSite.components(separatedBy: "https://")[1]
    }

    var proSite: String {
        return Global.mainSite + "pro.php?lt=" + Preferences.linkToken
    }

    var themeSection: [Static.Section] {
        return [
            Section(header: .title("User Interface".localized()), rows: [
                Row(text: "Choose Theme".localized(),
                    detailText: Themes.current.toString, selection: { [unowned self] _ in
                        self.pushThemeChooser()
                    }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "Choose Language".localized(),
                    detailText: Localize.displayNameForLanguage(Localize.currentLanguage()), selection: { [unowned self] _ in
                        self.pushLanguageChooser()
                    }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ])
        ]
    }

    // Common sections shared between linked/non linked settings view

    var commonSections: [Static.Section] {
        return [
            Section(header: .title("Support".localized()), rows: [
                Row(text: "News".localized(), selection: { [unowned self] _ in
                    self.pushNews()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "System Status".localized(), selection: { [unowned self] _ in
                    self.pushSystemStatus()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "Contact Developer".localized(), selection: { _ in }, accessory: .disclosureIndicator, cellClass: ContactDevStaticCell.self),
                Row(text: "Visit appdb forum".localized(), detailText: forumSite, selection: { [unowned self] _ in
                    self.openInSafari(self.forumSite)
                }, accessory: .disclosureIndicator, cellClass: SimpleSubtitleCell.self)
            ]),

            Section(header: .title("About".localized()), rows: [
                Row(text: "Credits".localized(), selection: { [unowned self] _ in
                    self.pushCredits()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "Acknowledgements".localized(), selection: { [unowned self] _ in
                    self.pushAcknowledgements()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "Version".localized(), detailText: "\(Global.appVersion)", cellClass: SimpleStaticCell.self)
            ])
        ]
    }

    // Sections exclusive for the 'not linked' state

    var deviceNotLinkedSections: [Static.Section] {
        return themeSection + [
            Section(header: .title("General".localized()), rows: [
                Row(text: "Device".localized(), detailText: deviceInfoString, cellClass: SimpleStaticCell.self)
            ]),

            Section(rows: [
                Row(text: "Authorize App".localized(), selection: { [unowned self] _ in
                    self.pushDeviceLink()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticButtonCell.self,
                   context: ["bgColor": Color.slightlyDarkerMainTint, "bgHover": Color.darkMainTint])
            ], footer: .title("Authorize app with link code from appdb website and enjoy unlimited app installs!".localized()))
        ] + commonSections
    }

    // Sections exclusive for the 'linked' state

    var deviceLinkedSections: [Static.Section] {
        return themeSection + [

            Section(header: .title("General".localized()), rows: [
                Row(text: "Device".localized(), detailText: deviceInfoString, cellClass: SimpleStaticCell.self),

                Row(text: "PRO Status".localized(), selection: { [unowned self] _ in
                    if (Preferences.proRevoked) || (!Preferences.proDisabled && !Preferences.pro) {
                        self.openInSafari(self.proSite)
                    }
                }, cellClass: SimpleStaticPROStatusCell.self, context: ["active": Preferences.pro, "expire": Preferences.proUntil, "revoked": Preferences.proRevoked, "revokedOn": Preferences.proRevokedOn, "disabled": Preferences.proDisabled]),

                Row(text: "Link Code".localized(), detailText: Preferences.linkCode, selection: { [unowned self] _ in
                        API.getLinkCode(success: { self.refreshSources() }, fail: { _ in })
                    }, cellClass: SimpleStaticCell.self, context: ["disableSelection": true], copyAction: { row in
                        UIPasteboard.general.string = row.detailText
                    }
                )
            ], footer: .title("Use this code if you want to link new devices to appdb. Press and hold the cell to copy it, or tap it to generate a new one.".localized())),

            Section(header: .title("Device Configuration".localized()), rows: [
                Row(text: "Jailbroken w/ Appsync".localized(), accessory: .switchToggle(value: Preferences.appsync) { newValue in
                    API.setConfiguration(params: [.appsync: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),

                Row(text: "Compatibility Checks".localized(), accessory: .switchToggle(value: !Preferences.ignoresCompatibility) { newValue in
                    API.setConfiguration(params: [.ignoreCompatibility: newValue ? "no" : "yes"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),

                Row(text: "Ask for installation options".localized(), accessory: .switchToggle(value: Preferences.askForInstallationOptions) { newValue in
                    API.setConfiguration(params: [.askForOptions: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),

                Row(text: "Advanced Options".localized(), selection: { [unowned self] _ in
                    self.pushAdvancedOptions()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),

            Section(rows: [
                Row(text: "Show badge for updates".localized(), cellClass: SwitchCell.self, context: ["valueChange": { new in
                    Preferences.set(.showBadgeForUpdates, to: new)
                }, "value": Preferences.showBadgeForUpdates]),

                Row(text: "Change bundle id before upload".localized(), cellClass: SwitchCell.self, context: ["valueChange": { new in
                    Preferences.set(.changeBundleBeforeUpload, to: new)
                }, "value": Preferences.changeBundleBeforeUpload])
            ], footer: .title("Changing bundle identifier before uploading to MyAppStore might be useful when working with multiple versions of the same app.".localized())),

            Section(rows: [
                Row(text: "Device Status".localized(), selection: { [unowned self] _ in
                    self.pushDeviceStatus()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ])
        ] + commonSections + [

            Section(rows: [
                Row(text: "Deauthorize".localized(), selection: { [unowned self] _ in
                    self.showDeauthorizeConfirmation()
                }, cellClass: SimpleStaticButtonCell.self, context: ["bgColor": Color.softRed, "bgHover": Color.darkRed])
            ], footer: .title("To fully unlink your device from appdb remove its profile in Settings -> General -> Profiles.".localized())),

            Section()
        ]
    }
}
