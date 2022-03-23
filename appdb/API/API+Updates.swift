//
//  API+Updates.swift
//  appdb
//
//  Created by ned on 10/11/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {

    static func getUpdatesTicket(success:@escaping (_ ticket: String) -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.getUpdatesTicket.rawValue, "lang": languageCode], headers: headersWithCookie)
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

    static func getUpdates(ticket: String, success:@escaping (_ items: [UpdateableApp]) -> Void, fail:@escaping (_ error: String) -> Void) {
        let request = AF.request(endpoint, parameters: ["action": Actions.getUpdates.rawValue, "t": ticket, "lang": languageCode], headers: headersWithCookie)

        quickCheckForErrors(request, completion: { ok, hasError in
            if ok {
                request.responseArray(keyPath: "data") { (response: AFDataResponse<[UpdateableApp]>) in
                    switch response.result {
                    case .success(var items):

                        // Cleanup mismatch versions
                        for item in items {
                            var new = item.versionNew
                            var old = item.versionOld
                            new = new.replacingOccurrences(of: " ", with: "")
                            old = old.replacingOccurrences(of: " ", with: "")
                            if new.hasPrefix("v") { new = String(new.dropFirst()) }
                            if old.hasPrefix("v") { old = String(old.dropFirst()) }
                            if new.compare(old, options: .numeric) != .orderedDescending {
                                debugLog("found mismatch for \(item.name): new: \(new), old: \(old). Removing...")
                                items.remove(at: items.firstIndex(of: item)!)
                            }
                        }
                        success(items)
                    case .failure(let error):
                        fail(error.localizedDescription)
                    }
                }
            } else {
                fail(hasError ?? "Cannot connect".localized())
            }
        })
    }
}
