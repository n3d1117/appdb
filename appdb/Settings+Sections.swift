//
//  Settings+Sections.swift
//  appdb
//
//  Created by ned on 14/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Static

extension Settings {
    
    // Common sections shared between linked/non linked settings view
    
    var commonSections: [Static.Section] {
        return [
            Section(header: "ui", rows: [
                Row(text: "Dark Mode".localized(), accessory: .switchToggle(value: Themes.isNight) { newValue in
                    Themes.switchTo(theme: newValue ? .Dark : .Light)
                }, cellClass: SimpleStaticCell.self)
            ]),
            
            Section(header: "support", rows: [
                Row(text: "News".localized(), selection: { [unowned self] in
                    self.pushNews()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "System Status", selection: { [unowned self] in
                    self.pushSystemStatus()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "contact dev", accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "appdb forums", accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            
            Section(header: "about", rows: [
                Row(text: "Acknowledgements", accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self),
                Row(text: "Version", detailText: "\(Global.appVersion)", cellClass: SimpleStaticCell.self)
            ])
        ]
    }
    
    // Sections exclusive for the 'not linked' state
    
    var deviceNotLinkedSections: [Static.Section] {
        return [
            
            Section(header: "general", rows: [
                Row(text: "Device", detailText: "todo", cellClass: SimpleStaticCell.self),
            ]),
            
            Section(rows: [
                Row(text: "Authorize App".localized(), selection: { [unowned self] in
                    self.pushDeviceLink()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticButtonCell.self, context: ["bgColor": Color.mainTint])
            ])
        
        ] + commonSections
    }
    
    // Sections exclusive for the 'linked' state, todo localize
    
    var deviceLinkedSections: [Static.Section] {
        return [
            // todo localize
            Section(header: .title("Device".localized()), rows: [
                
                Row(text: "Device", detailText: "todo", cellClass: SimpleStaticCell.self),
                
                Row(text: "PRO Status".localized(), detailText: pro ? "ok, until \(proUntil)" : "Inactive",
                    cellClass: SimpleStaticCell.self),
                
                Row(text: "Link Code".localized(), detailText: linkCode, selection: { [unowned self] in
                    API.getLinkCode(success: { self.refreshSources() }, fail: { _ in })
                }, cellClass: SimpleStaticCell.self)
            ]),
            
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
            ], footer: "deauth_footer_text")
            
        ]
    }
    
}
