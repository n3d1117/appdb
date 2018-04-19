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
            
            Section(header: "...", rows: [
                Row(text: "News".localized(), selection: { [unowned self] in
                    self.pushNews()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ])
        ]
    }
    
    // Sections exclusive for the 'not linked' state
    
    var deviceNotLinkedSections: [Static.Section] {
        return [
            Section(header: "device", rows: [
                Row(text: "Authorize App".localized(), selection: { [unowned self] in
                    self.pushDeviceLink()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ])
        
        ] + commonSections
    }
    
    // Sections exclusive for the 'linked' state, todo localize
    
    var deviceLinkedSections: [Static.Section] {
        return [
            Section(header: .title("Device Configuration".localized()), rows: [
                
                Row(text: "Link Code".localized(), detailText: linkCode, selection: { [unowned self] in
                    API.getLinkCode(success: { self.refreshSources() }, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                // todo localize
                Row(text: "PRO Status".localized(), detailText: pro ? "ok, until \(proUntil)" : "Inactive", cellClass: SimpleStaticCell.self),
                
                Row(text: "Jailbroken w/ Appsync".localized(), accessory: .switchToggle(value: appsync) { newValue in
                    API.setConfiguration(params: [.appsync: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                Row(text: "Compatibility Checks".localized(), accessory: .switchToggle(value: !ignoresCompatibility) { newValue in
                    API.setConfiguration(params: [.ignoreCompatibility: newValue ? "no" : "yes"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                Row(text: "Ask for installation options".localized(), accessory: .switchToggle(value: askForInstallationOptions) { newValue in
                    API.setConfiguration(params: [.askForOptions: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                Row(text: "Deauthorize".localized(), selection: { [unowned self] in
                    self.deauthorize()
                }, cellClass: SimpleStaticButtonCell.self)
                
            ])
            
        ] + commonSections
    }
    
}
