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
        let jb = FileManager.default.fileExists(atPath: "/bin/bash") // lazy check
        return device.deviceType.displayName + " (" + device.systemVersion + ", \(jb ? "JB" : "Non-JB")" + ")"
    }
    
    var themeSection: [Static.Section] {
        return [
            Section(header: .title("User Interface".localized()), rows: [
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
            
            Section(header: "Support", rows: [
                Row(text: "News".localized(), selection: { [unowned self] in
                    self.pushNews()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "System Status".localized(), selection: { [unowned self] in
                    self.pushSystemStatus()
                }, accessory: .disclosureIndicator, cellClass: SimpleSubtitleCell.self),
                Row(text: "Visit appdb forum".localized(), detailText: "https://forum.appdb.to/", selection: { [unowned self] in
                    self.openInSafari("https://forum.appdb.to/")
                }, accessory: .disclosureIndicator, cellClass: SimpleSubtitleCell.self)
            ]),
            
            Section(header: "About", rows: [
                Row(text: "Acknowledgements".localized(), selection: { [unowned self] in
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
                Row(text: "Device".localized(), detailText: deviceInfoString, cellClass: SimpleStaticCell.self),
            ]),
            
            Section(rows: [
                Row(text: "Authorize App".localized(), selection: { [unowned self] in
                    self.pushDeviceLink()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticButtonCell.self, context: ["bgColor": Color.mainTint, "bgHover": Color.darkMainTint])
            ], footer: .title("Authorize app with link code from appdb website and enjoy unlimited app installs!".localized()))
        
        ] + commonSections
    }
    
    // Sections exclusive for the 'linked' state
    
    var deviceLinkedSections: [Static.Section] {
        return themeSection + [

            Section(header: .title("General".localized()), rows: [
                
                Row(text: "Device".localized(), detailText: deviceInfoString, cellClass: SimpleStaticCell.self),
                
                Row(text: "PRO Status".localized(), cellClass: SimpleStaticPROStatusCell.self,
                    context: ["active": pro, "expire": proUntil]),
                
                Row(text: "Link Code".localized(), detailText: linkCode, selection: { [unowned self] in
                        API.getLinkCode(success: { self.refreshSources() }, fail: { _ in })
                    }, cellClass: SimpleStaticCell.self, context: ["disableSelection": true], copyAction: { row in
                        UIPasteboard.general.string = row.detailText
                    }
                )
            ], footer: .title("Use this code if you want to link new devices to appdb. Press and hold the cell to copy it, or tap it to generate a new one.".localized())),
            
            Section(header: .title("Device Configuration".localized()), rows: [
                Row(text: "Jailbroken w/ Appsync".localized(), accessory: .switchToggle(value: appsync) { newValue in
                    API.setConfiguration(params: [.appsync: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                Row(text: "Compatibility Checks".localized(), accessory: .switchToggle(value: !ignoresCompatibility) { newValue in
                    API.setConfiguration(params: [.ignoreCompatibility: newValue ? "no" : "yes"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                Row(text: "Ask to duplicate app".localized(), accessory: .switchToggle(value: askForInstallationOptions) { newValue in
                    API.setConfiguration(params: [.askForOptions: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self)
            ]),
            
            Section(rows: [
                Row(text: "Device Status".localized(),  selection: { [unowned self] in
                    self.pushDeviceStatus()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            
        ] + commonSections + [
            
            Section(rows: [
                Row(text: "Deauthorize".localized(), selection: { [unowned self] in
                    self.deauthorize()
                    }, cellClass: SimpleStaticButtonCell.self, context: ["bgColor": Color.softRed, "bgHover": Color.darkRed])
            ], footer: .title("To fully unlink your device from appdb remove its profile in Settings -> General -> Profiles.".localized())),
            
            Section()
            
        ]
    }
    
}
