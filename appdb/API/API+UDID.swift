//
//  API+UDID.swift
//  appdb
//
//  Created by stev3fvcks on 23.08.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension API {

    static func getUDID(success: @escaping (String) -> Void, fail: @escaping (String) -> Void) {

        // Get UDID from managed configuration
        guard let deviceUdid = UserDefaults.standard.dictionary(forKey: "com.apple.configuration.managed")?["dbservicesUDID"] as? String else {
            AF.request(Global.signingCertsUdidApi + "&lt=\(Preferences.linkToken)", parameters: ["client": "appdb unofficial client"], headers: headers)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)

                        if !json["success"].boolValue {
                            fail("Invalid device link")
                        } else {
                            let email = json["data"]["email"].stringValue
                            let udid = json["data"]["udid"].stringValue
                            Preferences.set(.email, to: email)
                            Preferences.set(.udid, to: udid)

                            // Update link code
                            API.getLinkCode(success: {
                                success(udid)
                            }, fail: { error in
                                fail(error)
                            })
                        }
                    case .failure(let error):
                        fail(error.localizedDescription)
                    }
                }
            return
        }
        success(deviceUdid)
    }
}
