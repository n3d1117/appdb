//
//  API+DeviceLink.swift
//  appdb
//
//  Created by ned on 10/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {

    static func linkDevice(code: String, success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.link.rawValue, "type": "control", "link_code": code,
                                                 "lang": languageCode], headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        fail(json["errors"][0].stringValue)
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

    static func getLinkCode(success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.getLinkCode.rawValue, "lang": languageCode], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if !json["success"].boolValue {
                    fail(json["errors"][0].stringValue)
                } else {
                    Preferences.set(.linkCode, to: json["data"].stringValue)
                    success()
                }
            case .failure(let error):
                fail(error.localizedDescription)
            }
        }
    }

    static func emailLinkCode(email: String, success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["email": email, "action": Actions.emailLinkCode.rawValue], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if !json["success"].boolValue {
                    fail(json["errors"][0].stringValue)
                } else {
                    success()
                }
            case .failure(let error):
                fail(error.localizedDescription)
            }
        }
    }

    static func getAppdbAppsBundleIdsTicket(success:@escaping (_ ticket: String) -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.getAppdbAppsBundleIdsTicket.rawValue], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if !json["success"].boolValue {
                    fail(json["errors"][0].stringValue)
                } else {
                    success(json["data"].stringValue)
                }
            case .failure(let error):
                fail(error.localizedDescription)
            }
        }
    }

    static func getAppdbAppsBundleIds(ticket: String, success:@escaping (_ bundleIds: [String]) -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["t": ticket, "action": Actions.getAppdbAppsBundleIds.rawValue], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if !json["success"].boolValue {
                    fail(json["errors"][0].stringValue)
                } else {
                    success(json["data"].arrayValue.map { $0.stringValue})
                }
            case .failure(let error):
                fail(error.localizedDescription)
            }
        }
    }

    static func getAllLinkedDevices(success:@escaping (_ devices: [LinkedDevice]) -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.getAllDevices.rawValue], headers: headersWithCookie)
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
