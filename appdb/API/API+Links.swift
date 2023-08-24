//
//  API+Links.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension API {

    static func getLinks(type: ItemType, trackid: String, success: @escaping (_ items: [Version]) -> Void, fail: @escaping (_ error: String) -> Void) {
        AF.request(endpoint + Actions.getLinks.rawValue, parameters: ["type": type.rawValue, "trackids": trackid, "lang": languageCode], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):

                    let json = JSON(value)
                    let data = json["data"]
                    var versions: [Version] = []

                    let queue = DispatchQueue(label: "it.ned.links_\(trackid)", attributes: .concurrent)

                    queue.async {
                        // No multiple keys for books
                        if type == .books {
                            let fetched: JSON = data[trackid][0]
                            if !fetched.isEmpty {
                                var version = Version(number: Global.tilde)
                                for e in 0..<fetched.count {
                                    let link: JSON = fetched[e]
                                    var incompatibility_reason: String = ""
                                    if link["is_compatible"]["reason"].exists() {
                                        incompatibility_reason = link["is_compatible"]["reason"].stringValue
                                    }
                                    var report_reason: String = ""
                                    if !link["reports"].isEmpty && link["reports"].arrayValue.first!["reason"].exists() {
                                        report_reason = link["reports"].arrayValue.first!["reason"].stringValue
                                    }
                                    version.links.append(Link(
                                        link: link["link"].stringValue,
                                        cracker: link["cracker"].stringValue,
                                        uploader: link["uploader_name"].stringValue,
                                        host: link["host"].stringValue,
                                        id: link["id"].stringValue,
                                        verified: link["verified"].boolValue,
                                        di_compatible: link["di_compatible"].intValue == 1,
                                        hidden: link["is_hidden"] != "0",
                                        is_compatible: link["is_compatible"]["result"] == "yes",
                                        incompatibility_reason: incompatibility_reason,
                                        report_reason: report_reason
                                    ))
                                }; versions.append(version)
                            }
                        } else {
                            var keys: [String] = []
                            for (key, _) in data[trackid] where !data[trackid][key].isEmpty {
                                keys.append(key)
                            }

                            keys.sort { $0.compare($1, options: .numeric) == .orderedDescending }

                            for key in keys {
                                var version = Version(number: key), fetched: JSON = data[trackid][key]
                                for e in 0..<fetched.count {
                                    let link: JSON = fetched[e]
                                    var incompatibility_reason: String = ""
                                    if link["is_compatible"]["reason"].exists() {
                                        incompatibility_reason = link["is_compatible"]["reason"].stringValue
                                    }
                                    var report_reason: String = ""
                                    if !link["reports"].isEmpty && link["reports"].arrayValue.first!["reason"].exists() {
                                        report_reason = link["reports"].arrayValue.first!["reason"].stringValue
                                    }
                                    version.links.append(Link(
                                        link: link["link"].stringValue,
                                        cracker: link["cracker"].stringValue,
                                        uploader: link["uploader_name"].stringValue,
                                        host: link["host"].stringValue,
                                        id: link["id"].stringValue,
                                        verified: link["verified"].boolValue,
                                        di_compatible: link["di_compatible"].intValue == 1,
                                        hidden: link["is_hidden"] != "0",
                                        is_compatible: link["is_compatible"]["result"] == "yes",
                                        isTicket: link["link"].stringValue.starts(with: "ticket://"),
                                        incompatibility_reason: incompatibility_reason,
                                        report_reason: report_reason
                                    ))
                                }
                                versions.append(version)
                            }
                        }

                        DispatchQueue.main.async {
                            success(versions)
                        }
                    }

                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }

    static func reportLink(id: String, type: ItemType, reason: String, completion: @escaping (_ error: String?) -> Void) {
        AF.request(endpoint + Actions.report.rawValue, parameters: ["type": type.rawValue, "id": id, "reason": reason, "lang": languageCode], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        completion(json["errors"][0]["translated"].stringValue)
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
    }

    static func getRedirectionTicket(t: String, completion: @escaping (_ error: String?, _ rt: String?, _ wait: Int?) -> Void) {

        guard var ticket = t.components(separatedBy: "ticket://").last else { return }

        // If I don't do this, '%3D' gets encoded to '%253D' which makes the ticket invalid
        ticket = ticket.replacingOccurrences(of: "%3D", with: "=")

        AF.request(endpoint + Actions.processRedirect.rawValue, parameters: ["t": ticket, "lang": languageCode], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        completion(json["errors"][0]["translated"].stringValue, nil, nil)
                    } else {
                        let rt: String = json["data"]["redirection_ticket"].stringValue
                        let wait: Int = json["data"]["wait"].intValue
                        completion(nil, rt, wait)
                    }
                case .failure(let error):
                    completion(error.localizedDescription, nil, nil)
                }
            }
    }

    static func getPlainTextLink(rt: String, completion: @escaping (_ error: String?, _ link: String?) -> Void) {
        AF.request(endpoint + Actions.processRedirect.rawValue, parameters: ["rt": rt, "lang": languageCode], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        completion(json["errors"][0]["translated"].stringValue, nil)
                    } else {
                        completion(nil, json["data"]["link"].stringValue)
                    }
                case .failure(let error):
                    completion(error.localizedDescription, nil)
                }
            }
    }
}
