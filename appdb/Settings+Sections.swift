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
    
    
    func deviceNotLinkedSections() -> [Static.Section] { return
        [
            Section(header: "device", rows: [
                Row(text: "Authorize App".localized(), selection: { [unowned self] in
                    self.pushDeviceLink()
                }, accessory: .disclosureIndicator, cellClass: SimpleStaticCell.self)
            ]),
            
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
    
    func deviceLinkedSections() -> [Static.Section] { return
        [
            Section(header: "device", rows: [
                Row(text: "Link Code".localized(), detailText: linkCode, selection: { [unowned self] in
                    API.getLinkCode(success: {
                        self.setDataSources()
                    }, fail: { error in
                        print(error)
                    })
                }),
                
                Row(text: "Deauthorize", selection: { [unowned self] in
                    self.deauthorize()
                }, cellClass: ButtonCell.self)
            ]),
            
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
    
}
