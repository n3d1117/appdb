//
//  API+DeviceLink.swift
//  appdb
//
//  Created by ned on 10/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension API {

    static func linkAutomaticallyUsingUDID(success: @escaping () -> Void, fail: @escaping () -> Void) {

        // Get UDID from managed configuration
        guard let deviceUdid = UserDefaults.standard.dictionary(forKey: "com.apple.configuration.managed")?["dbservicesUDID"] as? String else {
            fail()
            return
        }

        AF.request(endpoint + Actions.getLinkToken.rawValue, parameters: ["udid": deviceUdid, "client": "appdb unofficial client"], headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)

                    if !json["success"].boolValue {
                        fail()
                    } else {
                        let linkToken = json["data"].stringValue
                        Preferences.set(.token, to: linkToken)

                        // Update link code
                        API.getLinkCode(success: {
                            success()
                        }, fail: { error in
                            fail()
                        })
                    }
                case .failure(let error):
                    fail()
                }
            }
    }

    static func linkDevice(code: String, success: @escaping () -> Void, fail: @escaping (_ error: String) -> Void) {
        AF.request(endpoint + Actions.link.rawValue, parameters: ["type": "control", "link_code": code,
                                                 "lang": languageCode], headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        fail(json["errors"][0]["translated"].stringValue)
                    } else {
                        // Save token
                        Preferences.set(.token, to: json["data"]["link_token"].stringValue)

                        // Update link code
                        API.getLinkCode(success: {
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

    static func getLinkCode(success: @escaping () -> Void, fail: @escaping (_ error: String) -> Void) {
        AF.request(endpoint + Actions.getLinkCode.rawValue, parameters: ["lang": languageCode], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if !json["success"].boolValue {
                    fail(json["errors"][0]["translated"].stringValue)
                } else {
                    Preferences.set(.linkCode, to: json["data"].stringValue)
                    success()
                }
            case .failure(let error):
                fail(error.localizedDescription)
            }
        }
    }

    static func emailLinkCode(email: String, success: @escaping () -> Void, fail: @escaping (_ error: String) -> Void) {
        AF.request(endpoint + Actions.emailLinkCode.rawValue, parameters: ["email": email,
                                          "lang": languageCode], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if !json["success"].boolValue {
                    fail(json["errors"][0]["translated"].stringValue)
                } else {
                    success()
                }
            case .failure(let error):
                fail(error.localizedDescription)
            }
        }
    }

    static func getAppdbAppsBundleIdsTicket(success: @escaping (_ ticket: String) -> Void, fail: @escaping (_ error: String) -> Void) {
        AF.request(endpoint + Actions.getAppdbAppsBundleIdsTicket.rawValue, parameters: ["lang": languageCode], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if !json["success"].boolValue {
                    fail(json["errors"][0]["translated"].stringValue)
                } else {
                    success(json["data"].stringValue)
                }
            case .failure(let error):
                fail(error.localizedDescription)
            }
        }
    }

    static func getAppdbAppsBundleIds(ticket: String, success: @escaping (_ bundleIds: [String]) -> Void, fail: @escaping (_ error: String, _ code: String) -> Void) {
        AF.request(endpoint + Actions.getAppdbAppsBundleIds.rawValue, parameters: ["t": ticket,
                                          "lang": languageCode], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if !json["success"].boolValue {
                    fail(json["errors"][0]["translated"].stringValue, json["errors"][0]["code"].stringValue)
                } else {
                    success(json["data"].arrayValue.map { $0.stringValue})
                }
            case .failure(let error):
                fail(error.localizedDescription, "")
            }
        }
    }

    static func getAllLinkedDevices(success: @escaping (_ devices: [LinkedDevice]) -> Void, fail: @escaping (_ error: String) -> Void) {
        AF.request(endpoint + Actions.getAllDevices.rawValue, parameters: ["lang": languageCode], headers: headersWithCookie)
            .responseArray(keyPath: "data") { (response: AFDataResponse<[LinkedDevice]>) in
                switch response.result {
                case .success(let devices):
                    success(devices)
                case .failure(let error as NSError):
                    fail(error.localizedDescription)
                }
            }
    }
}
