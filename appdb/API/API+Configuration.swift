//
//  API+Configuration.swift
//  appdb
//
//  Created by ned on 14/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension API {

    static func getEnterpriseCerts(success: @escaping (_ items: [EnterpriseCertificate]) -> Void, fail: @escaping (_ error: NSError) -> Void) {
        AF.request(endpoint + Actions.getEnterpriseCerts.rawValue, parameters: ["lang": languageCode], headers: headersWithCookie)
            .responseArray(keyPath: "data") { (response: AFDataResponse<[EnterpriseCertificate]>) in
                switch response.result {
                case .success(let certs):
                    success(certs)
                case .failure(let error):
                    fail(error as NSError)
                }
            }
    }

    static func getConfiguration(success: @escaping () -> Void, fail: @escaping (_ error: String) -> Void) {
        AF.request(endpoint + Actions.getConfiguration.rawValue, parameters: ["lang": languageCode], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        fail(json["errors"][0]["translated"].stringValue)
                    } else {

                        let data = json["data"]
                        // checkRevocation(completion: { isRevoked, revokedOn in
                            Preferences.set(.appsync, to: data["appsync"].stringValue == "yes")
                            Preferences.set(.ignoreCompatibility, to: data["ignore_compatibility"].stringValue == "yes")
                            Preferences.set(.askForInstallationOptions, to: data["ask_for_installation_options"].stringValue == "yes")

                            // Preferences.set(.revoked, to: isRevoked)
                            // Preferences.set(.revokedOn, to: revokedOn)

                            if !data["p12_password"].stringValue.isEmpty, !data["p12"].stringValue.isEmpty, !data["provision"].stringValue.isEmpty {
                                Preferences.set(.usesCustomDeveloperIdentity, to: true)
                            } else {
                                Preferences.set(.usesCustomDeveloperIdentity, to: false)
                            }

                            Preferences.set(.email, to: data["email"].stringValue)
                            Preferences.set(.deviceName, to: data["name"].stringValue)
                            Preferences.set(.deviceVersion, to: data["ios_version"].stringValue)

                            // Preferences.set(.isPlus, to: data["is_plus"].stringValue == "yes")
                            let plusUntil = data["plus_till"].stringValue
                            let formatter = DateFormatter()
                            formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC 2822
                            formatter.locale = Locale(identifier: "en_US")
                            if let plusUntilDate = formatter.date(from: plusUntil) {
                                Preferences.set(.isPlus, to: plusUntilDate.timeIntervalSince1970 > Date().timeIntervalSince1970)
                            }
                            Preferences.set(.plusUntil, to: data["plus_till"].stringValue)
                            Preferences.set(.enterpriseCertId, to: data["enterprise_cert_id"].stringValue)
                            Preferences.set(.signingWith, to: data["signing_with"].stringValue)
                            Preferences.set(.freeSignsLeft, to: data["free_signs_left"].stringValue)
                            Preferences.set(.freeSignsResetAt, to: data["free_signs_reset_at"].stringValue)

                            Preferences.set(.plusStatus, to: data["plus_account"]["status"].stringValue)
                            Preferences.set(.plusStatusTranslated, to: data["plus_account"]["status_translated"].stringValue)

                            Preferences.set(.disableRevocationChecks, to: data["disable_protection_checks"].stringValue == "yes")
                            Preferences.set(.forceDisablePRO, to: data["is_pro_disabled"].stringValue == "yes")
                            Preferences.set(.signingIdentityType, to: data["signing_identity_type"].stringValue)
                            Preferences.set(.optedOutFromEmails, to: data["is_opted_out_from_emails"].stringValue == "yes")

                            success()
                        // }, fail: { error in
                        //    fail(error)
                        // })
                    }
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }

    static func setConfiguration(params: [ConfigurationParameters: String], success: @escaping () -> Void, fail: @escaping (_ error: String) -> Void) {
        var parameters: [String: Any] = ["lang": languageCode]
        for (key, value) in params { parameters[key.rawValue] = value }

        AF.request(endpoint + Actions.configure.rawValue, parameters: parameters, headers: headersWithCookie)
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
                            case .enterpriseCertId: Preferences.set(.enterpriseCertId, to: value)
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

    /*static func checkRevocation(completion: @escaping (_ revoked: Bool, _ revokedOn: String) -> Void, fail: @escaping (_ error: String) -> Void) {
        AF.request(endpoint + Actions.checkRevoke.rawValue, headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(!json["success"].boolValue, json["data"].stringValue)
            case .failure(let error):
                fail(error.localizedDescription)
            }
        }
    }*/
}
