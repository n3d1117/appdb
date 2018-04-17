//
//  Settings+Sections.swift
//  appdb
//
//  Created by ned on 14/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Static
import RealmSwift //todo remove

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
    
    // Sections exclusive for the 'linked' state
    
    var deviceLinkedSections: [Static.Section] {
        return [
            Section(header: "device", rows: [
                
                Row(text: "Link Code".localized(), detailText: linkCode, selection: { [unowned self] in
                    API.getLinkCode(success: { self.refreshSources() }, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                Row(text: "Jailbroken w/ Appsync", accessory: .switchToggle(value: appsync) { newValue in
                    API.setConfiguration(params: [.appsync: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                Row(text: "Compatibility Checks", accessory: .switchToggle(value: !ignoresCompatibility) { newValue in
                    API.setConfiguration(params: [.ignoreCompatibility: newValue ? "no" : "yes"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                Row(text: "Ask for installation options", accessory: .switchToggle(value: askForInstallationOptions) { newValue in
                    API.setConfiguration(params: [.askForOptions: newValue ? "yes" : "no"], success: {}, fail: { _ in })
                }, cellClass: SimpleStaticCell.self),
                
                Row(text: "Deauthorize", selection: { [unowned self] in
                    self.deauthorize()
                }, cellClass: SimpleStaticButtonCell.self)
                
            ])
            
        ] + commonSections
    }
    
}
