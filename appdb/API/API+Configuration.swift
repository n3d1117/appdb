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
        AF.request(endpoint, parameters: ["action": Actions.getConfiguration.rawValue,
                                                 "lang": languageCode], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        fail(json["errors"][0]["translated"].stringValue)
                    } else {

                        let data = json["data"]
                        checkRevocation(completion: { isRevoked, revokedOn in
                            Preferences.set(.appsync, to: data["appsync"].stringValue == "yes")
                            Preferences.set(.ignoreCompatibility, to: data["ignore_compatibility"].stringValue == "yes")
                            Preferences.set(.askForInstallationOptions, to: data["ask_for_installation_options"].stringValue == "yes")

                            Preferences.set(.proRevoked, to: isRevoked)
                            Preferences.set(.proRevokedOn, to: revokedOn)
                            if Preferences.proRevoked {
                                Preferences.set(.pro, to: false)
                            } else {
                                Preferences.set(.pro, to: data["is_pro"].stringValue == "yes")
                            }
                            Preferences.set(.proUntil, to: data["pro_till"].stringValue)

                            if !data["p12_password"].stringValue.isEmpty, !data["p12"].stringValue.isEmpty, !data["provision"].stringValue.isEmpty {
                                if Preferences.pro {
                                    Preferences.set(.usesCustomDeveloperIdentity, to: data["is_pro_disabled"].stringValue == "yes")
                                } else {
                                    Preferences.set(.usesCustomDeveloperIdentity, to: true)
                                }
                            } else {
                                Preferences.set(.usesCustomDeveloperIdentity, to: false)
                            }

                            Preferences.set(.deviceName, to: data["name"].stringValue)
                            Preferences.set(.deviceVersion, to: data["ios_version"].stringValue)
                            Preferences.set(.disableRevocationChecks, to: data["disable_protection_checks"].stringValue == "yes")
                            Preferences.set(.forceDisablePRO, to: data["is_pro_disabled"].stringValue == "yes")
                            Preferences.set(.signingIdentityType, to: data["signing_identity_type"].stringValue)
                            Preferences.set(.optedOutFromEmails, to: data["is_opted_out_from_emails"].stringValue == "yes")

                            success()
                        }, fail: { error in
                            fail(error)
                        })
                    }
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }

    static func setConfiguration(params: [ConfigurationParameters: String], success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
        var parameters: [String: Any] = ["action": Actions.configure.rawValue, "lang": languageCode]
        for (key, value) in params { parameters[key.rawValue] = value }

        AF.request(endpoint, parameters: parameters, headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                       fail(json["errors"][0]["translated"].stringValue)
                    } else {
                        // Update values
                        for (key, value) in params {
                            switch key {
                            case .appsync: Preferences.set(.appsync, to: value == "yes")
                            case .askForOptions: Preferences.set(.askForInstallationOptions, to: value == "yes")
                            case .ignoreCompatibility: Preferences.set(.ignoreCompatibility, to: value == "yes")
                            case .disableProtectionChecks: Preferences.set(.disableRevocationChecks, to: value == "yes")
                            case .forceDisablePRO: Preferences.set(.forceDisablePRO, to: value == "yes")
                            case .clearDevEntity: break
                            case .signingIdentityType: Preferences.set(.signingIdentityType, to: value)
                            case .optedOutFromEmails: Preferences.set(.optedOutFromEmails, to: value == "yes")
                            }
                        }
                        success()
                    }
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }

    static func checkRevocation(completion: @escaping (_ revoked: Bool, _ revokedOn: String) -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.checkRevoke.rawValue], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(!json["success"].boolValue, json["data"].stringValue)
            case .failure(let error):
                fail(error.localizedDescription)
            }
        }
    }
}
