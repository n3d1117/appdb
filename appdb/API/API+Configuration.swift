//
//  API+Configuration.swift
//  appdb
//
//  Created by ned on 14/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {
    
    static func getConfiguration(success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.getConfiguration.rawValue,
                                                 "lang": languageCode], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        fail(json["errors"][0].stringValue)
                    } else {
                        Alamofire.request(endpoint, parameters: ["action": Actions.checkRevoke.rawValue], headers: headersWithCookie)
                            .responseJSON { response1 in
                                switch response1.result {
                                case .success(let value1):
                                    let json2 = JSON(value1)
                                    let data = json["data"]

                                    Preferences.set(.appsync, to: data["appsync"].stringValue=="yes")
                                    Preferences.set(.ignoreCompatibility, to: data["ignore_compatibility"].stringValue=="yes")
                                    Preferences.set(.askForInstallationOptions, to: data["ask_for_installation_options"].stringValue=="yes")

                                    Preferences.set(.pro, to: data["is_pro"].stringValue=="yes")
                                    Preferences.set(.proDisabled, to: data["is_pro_disabled"].stringValue=="yes")
                                    Preferences.set(.proRevoked, to: !json2["success"].boolValue)
                                    Preferences.set(.proRevokedOn, to: json2["data"].stringValue)
                                    Preferences.set(.proUntil, to: data["pro_till"].stringValue)

                                    success()

                                case .failure(let error):
                                    fail(error.localizedDescription)
                                }
                            }
                    }
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }

    static func setConfiguration(params: [ConfigurationParameters: String], success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
        var parameters: [String: Any] = ["action": Actions.configure.rawValue, "lang": languageCode]
        for (key, value) in params { parameters[key.rawValue] = value }

        Alamofire.request(endpoint, parameters: parameters, headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                       fail(json["errors"][0].stringValue)
                    } else {
                        // Update values
                        for (key, value) in params {
                            switch key {
                            case .appsync: Preferences.set(.appsync, to: value == "yes")
                            case .askForOptions: Preferences.set(.askForInstallationOptions, to: value == "yes")
                            case .ignoreCompatibility: Preferences.set(.ignoreCompatibility, to: value == "yes")
                            }
                        }
                        success()
                    }
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }
}
