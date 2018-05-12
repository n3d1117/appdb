//
//  Settings+Sections.swift
//  appdb
//
//  Created by ned on 14/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Static
import UIKit

extension Settings {
    
    // Device info string, e.g. "iPhone 6s (10.2, JB)"
    var deviceInfoString: String {
        let device = UIDevice.current
        let jb = FileManager.default.fileExists(atPath: "/bin/bash")
        return device.deviceType.displayName + " (" + device.systemVersion + ", \(jb ? "JB" : "Non-JB")" + ")"
    }
    
    var themeSection: [Static.Section] {
        return [
            Section(header: "user interface", rows: [
                Row(text: "Choose Theme".localized(),
                    detailText: Themes.isNight ? "Dark".localized() : "Light".localized(), selection: { [unowned self] in
                    self.pushThemeChooser()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ])
        ]
    }
    
    // Common sections shared between linked/non linked settings view
    
    var commonSections: [Static.Section] {
        return [
            
            Section(header: "support", rows: [
                Row(text: "News".localized(), selection: { [unowned self] in
                    self.pushNews()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "System Status".localized(), detailText: "https://status.appdb.store", selection: { [unowned self] in
                    self.pushSystemStatus()
                }, accessory: .disclosureIndicator, cellClass: SimpleSubtitleCell.self),
                Row(text: "Contact Developer", detailText: "https://t.me/ne_do", selection: { [unowned self] in
                    self.openTelegramLink()
                }, accessory: .disclosureIndicator, cellClass: SimpleSubtitleCell.self),
                Row(text: "Visit appdb forums", detailText: "https://forum.appdb.store/", selection: { [unowned self] in
                    self.openInSafari("https://forum.appdb.store/")
                }, accessory: .disclosureIndicator, cellClass: SimpleSubtitleCell.self)
            ]),
            
            Section(header: "about", rows: [
                Row(text: "Acknowledgements", selection: { [unowned self] in
                    self.pushAcknowledgements()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "Version", detailText: "\(Global.appVersion)", cellClass: SimpleStaticCell.self)
            ])
        ]
    }
    
    // Sections exclusive for the 'not linked' state
    
    var deviceNotLinkedSections: [Static.Section] {
        return themeSection + [
            
            Section(header: "general", rows: [
                Row(text: "Device", detailText: deviceInfoString, cellClass: SimpleStaticCell.self),
            ]),
            
            Section(rows: [
                Row(text: "Authorize App".localized(), selection: { [unowned self] in
                    self.pushDeviceLink()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticButtonCell.self, context: ["bgColor": Color.mainTint])
            ], footer: "Authorize app with link code from appdb website and enjoy unlimited app installs!")
        
        ] + commonSections
    }
    
    // Sections exclusive for the 'linked' state, todo localize
    
    var deviceLinkedSections: [Static.Section] {
        return themeSection + [

            Section(header: .title("Device".localized()), rows: [
                
                Row(text: "Device", detailText: deviceInfoString, cellClass: SimpleStaticCell.self),
                
                Row(text: "PRO Status".localized(), cellClass: SimpleStaticPROStatusCell.self,
                    context: ["active": pro, "expire": proUntil]),
                
                Row(text: "Link Code".localized(), detailText: linkCode, selection: { [unowned self] in
                        API.getLinkCode(success: { self.refreshSources() }, fail: { _ in })
                    }, cellClass: SimpleStaticCell.self, context: ["disableSelection": true], copyAction: { row in
                        UIPasteboard.general.string = row.detailText
                    }
                )
            ], footer: "Use this code if you want to link new devices to appdb. Press and hold the cell to copy it, or tap it to generate a new one."),
            
            Section(header: .title("Device Configuration".localized()), rows: [
                Row(text: "Jailbroken w/ Appsync".localized(), accessory: .switchToggle(value: appsync) { newValue in
                    API.setConfiguration(params: [.appsync: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                Row(text: "Compatibility Checks".localized(), accessory: .switchToggle(value: !ignoresCompatibility) { newValue in
                    API.setConfiguration(params: [.ignoreCompatibility: newValue ? "no" : "yes"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                Row(text: "Ask for installation options".localized(), accessory: .switchToggle(value: askForInstallationOptions) { newValue in
                    API.setConfiguration(params: [.askForOptions: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self)
            ]),
            
            Section(rows: [
                Row(text: "Device Status".localized(), accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            
        ] + commonSections + [
            
            Section(rows: [
                Row(text: "Deauthorize".localized(), selection: { [unowned self] in
                    self.deauthorize()
                }, cellClass: SimpleStaticButtonCell.self, context: ["bgColor": Color.softRed])
            ], footer: "To fully unlink your device from appdb remove its profile in Settings -> General -> Profiles."),
            
            Section()
            
        ]
    }
    
}
