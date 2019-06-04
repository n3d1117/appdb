//
//  API+CheckAppUpdate.swift
//  appdb
//
//  Created by ned on 28/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Foundation
import SwiftyJSON

extension API {

    static func checkIfUpdateIsAvailable(success:@escaping (CydiaApp, String) -> Void) {

        let trackid: String = "1900000538"
        let currentVersion: String = Global.appVersion

        API.search(type: CydiaApp.self, trackid: trackid, success: { apps in
            if let app = apps.first {
                if app.version.compare(currentVersion, options: .numeric) == .orderedDescending {
                    API.getLinks(type: .cydia, trackid: trackid, success: { versions in
                        if let firstLink = versions.first(where: { $0.number == app.version })?.links.first {
                            success(app, firstLink.id)
                        }
                    }, fail: { _ in })
                }
            }
        }, fail: { _ in })
    }
}
