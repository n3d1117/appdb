//
//  API+Links.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {

    static func getLinks(type: ItemType, trackid: String, success:@escaping (_ items: [Version]) -> Void, fail:@escaping (_ error: String) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.getLinks.rawValue, "type": type.rawValue, "trackids": trackid], headers: headersWithCookie)
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
                                    version.links.append(Link(
                                        link: link["link"].stringValue,
                                        cracker: link["cracker"].stringValue,
                                        uploader: link["uploader_name"].stringValue,
                                        host: link["host"].stringValue,
                                        id: link["id"].stringValue,
                                        verified: link["verified"].boolValue,
                                        di_compatible: link["di_compatible"].boolValue,
                                        hidden: link["is_hidden"] != "0",
                                        universal: link["is_universal"] != "0"
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
                                    version.links.append(Link(
                                        link: link["link"].stringValue,
                                        cracker: link["cracker"].stringValue,
                                        uploader: link["uploader_name"].stringValue,
                                        host: link["host"].stringValue,
                                        id: link["id"].stringValue,
                                        verified: link["verified"].boolValue,
                                        di_compatible: link["di_compatible"].boolValue,
                                        hidden: link["is_hidden"] != "0",
                                        universal: link["is_universal"] != "0"
                                    ))
                                }; versions.append(version)
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

    static func reportLink(id: String, type: ItemType, reason: String, completion:@escaping (_ error: String?) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.report.rawValue, "type": type.rawValue, "id": id, "reason": reason], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        completion(json["errors"][0].stringValue)
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
    }
}
