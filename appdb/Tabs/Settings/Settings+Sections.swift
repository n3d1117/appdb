//
//  Settings+Sections.swift
//  appdb
//
//  Created by ned on 14/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Localize_Swift

extension Settings {

    // Device info string, e.g. "iPhone 6s (10.2)"
    var deviceInfoString: String {
        let device = UIDevice.current
        if !Preferences.deviceName.isEmpty {
            return Preferences.deviceName + " (" + Preferences.deviceVersion + ")"
        } else {
            return device.deviceType.displayName + " (" + device.systemVersion + ")"
        }
    }

    var forumSite: String {
        "https://forum." + Global.mainSite.components(separatedBy: "https://")[1]
    }

    var proSite: String {
        Global.mainSite + "my/buy?ref=" + Global.refCode + "&lt=" + Preferences.linkToken
    }

    var themeSection: [StaticSection] {
        var rows: [StaticRow] = [
            StaticRow(text: "Choose Theme".localized(),
                detailText: Themes.current.toString, selection: { [unowned self] _ in
                    self.push(ThemeChooser())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
            StaticRow(text: "Choose Language".localized(),
                detailText: Localize.displayNameForLanguage(Localize.currentLanguage()), selection: { [unowned self] _ in
                    self.push(LanguageChooser())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
        ]

        if UIApplication.shared.supportsAlternateIcons {
            rows.append(
                StaticRow(text: "Choose Icon".localized(), selection: { [unowned self] _ in
                    self.push(IconChooser())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            )
        }

        return [
            StaticSection(header: .title("User Interface".localized()), rows: rows)
        ]
    }

    // Common sections shared between linked/non linked settings view

    var commonSections: [StaticSection] {
        [
            StaticSection(header: .title("Support".localized()), rows: [
                StaticRow(text: "News".localized(), selection: { [unowned self] _ in
                    self.push(News())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                StaticRow(text: "System Status".localized(), selection: { [unowned self] _ in
                    self.push(SystemStatus())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                StaticRow(text: "Contact Developer".localized(), selection: { _ in }, accessory: .disclosureIndicator, cellClass: ContactDevStaticCell.self),
                StaticRow(text: "Visit appdb forum".localized(), detailText: forumSite, selection: { [unowned self] _ in
                    self.openInSafari(self.forumSite)
                }, accessory: .disclosureIndicator, cellClass: SimpleSubtitleCell.self)
            ]),

            StaticSection(header: .title("About".localized()), rows: [
                StaticRow(text: "Credits".localized(), selection: { [unowned self] _ in
                    self.push(Credits())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                StaticRow(text: "Acknowledgements".localized(), selection: { [unowned self] _ in
                    self.push(Acknowledgements())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                StaticRow(text: "Clear Cache".localized(), detailText: Settings.cacheFolderReadableSize(), selection: { _ in },
                    accessory: .disclosureIndicator, cellClass: ClearCacheStaticCell.self),
                StaticRow(text: "Version".localized(), detailText: "\(Global.appVersion)", cellClass: SimpleStaticCell.self)
            ])
        ]
    }

    // Sections exclusive for the 'not linked' state

    var deviceNotLinkedSections: [StaticSection] {
        themeSection + [
            StaticSection(header: .title("General".localized()), rows: [
                StaticRow(text: "Device".localized(), detailText: deviceInfoString, cellClass: SimpleStaticCell.self)
            ]),

            StaticSection(rows: [
                StaticRow(text: "Authorize App".localized(), selection: { [unowned self] _ in
                    self.pushDeviceLink()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticButtonCell.self,
                   context: ["bgColor": Color.slightlyDarkerMainTint, "bgHover": Color.darkMainTint])
            ], footer: .title("Authorize app with link code from appdb website and enjoy unlimited app installs!".localized()))
        ] + commonSections
    }

    // Sections exclusive for the 'linked' state

    var deviceLinkedSections: [StaticSection] {
        themeSection + [

            StaticSection(header: .title("General".localized()), rows: [
                StaticRow(text: "Device".localized(), detailText: deviceInfoString, selection: { [unowned self] _ in
                    self.push(DeviceChooser())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),

                StaticRow(text: "Signing".localized(), selection: { [unowned self] _ in
                    let certificateChooser = EnterpriseCertChooser()
                    certificateChooser.changedCertDelegate = self
                    self.push(certificateChooser)
                }, cellClass: SimpleStaticSigningCertificateCell.self, context: ["signingWith": Preferences.signingWith, "isPlus": Preferences.isPlus, "plusUntil": Preferences.plusUntil, "plusAccountStatus": Preferences.plusAccountStatusTranslated, "enterpriseCertId": Preferences.enterpriseCertId, "freeSignsLeft": Preferences.freeSignsLeft, "freeSignsResetAt": Preferences.freeSignsResetAt, "revoked": Preferences.revoked, "revokedOn": Preferences.revokedOn, "usesCustomDevIdentity": Preferences.usesCustomDeveloperIdentity]),

                StaticRow(text: "PLUS Status".localized(), selection: { [unowned self] _ in
                    if !Preferences.isPlus {
                        self.push(PlusPurchase())
                    }
                    }, cellClass: SimpleStaticPLUSStatusCell.self, context: ["active": Preferences.isPlus, "expire": Preferences.plusUntil]),

                StaticRow(text: "Link Code".localized(), detailText: Preferences.linkCode, selection: { [unowned self] _ in
                        API.getLinkCode(success: { self.refreshSources() }, fail: { _ in })
                    }, cellClass: SimpleStaticCell.self, context: ["disableSelection": true], copyAction: { row in
                        UIPasteboard.general.string = row.detailText
                    }
                )
            ], footer: .title("Use this code if you want to link new devices to appdb. Press and hold the cell to copy it, or tap it to generate a new one.".localized())),

            StaticSection(header: .title("Device Configuration".localized()), rows: [
                StaticRow(text: "Jailbroken w/ Appsync".localized(), accessory: .switchToggle(value: Preferences.appsync) { newValue in
                    API.setConfiguration(params: [.appsync: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),

                StaticRow(text: "Compatibility Checks".localized(), accessory: .switchToggle(value: !Preferences.ignoresCompatibility) { newValue in
                    API.setConfiguration(params: [.ignoreCompatibility: newValue ? "no" : "yes"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),

                StaticRow(text: "Ask for installation options".localized(), accessory: .switchToggle(value: Preferences.askForInstallationOptions) { newValue in
                    API.setConfiguration(params: [.askForOptions: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),

                StaticRow(text: "IPA Cache".localized(), selection: { [unowned self] _ in
                    self.push(IPACache())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),

                StaticRow(text: "Advanced Options".localized(), selection: { [unowned self] _ in
                    self.push(AdvancedOptions())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            StaticSection(rows: [
                StaticRow(text: "Device Status".localized(), selection: { [unowned self] _ in
                    self.push(DeviceStatus())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            StaticSection(rows: [
                StaticRow(text: "My Dylibs, Frameworks and Debs".localized(), selection: { [unowned self] _ in
                    self.push(MyDylibs())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            StaticSection(rows: [
                StaticRow(text: "AltStore Repos".localized(), selection: { [unowned self] _ in
                    self.push(AltStoreRepos())
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            StaticSection(rows: [
                StaticRow(text: "Show badge for updates".localized(), cellClass: SwitchCell.self, context: ["valueChange": { new in
                    Preferences.set(.showBadgeForUpdates, to: new)
                }, "value": Preferences.showBadgeForUpdates])
            ])
        ] + commonSections + [

            StaticSection(rows: [
                StaticRow(text: "Deauthorize".localized(), selection: { [unowned self] _ in
                    self.showDeauthorizeConfirmation()
                }, cellClass: SimpleStaticButtonCell.self, context: ["bgColor": Color.softRed, "bgHover": Color.darkRed])
            ], footer: .title("To fully unlink your device from appdb remove its profile in Settings -> General -> Profiles.".localized())),

            StaticSection()
        ]
    }
}
