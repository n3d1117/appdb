//
//  API+Links.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension API {
    
    static func getLinks(type: ItemType, trackid: String, success:@escaping (_ items: [Version]) -> Void, fail:@escaping (_ error: String) -> Void) {
        
        Alamofire.request(endpoint, parameters: ["action": Actions.getLinks.rawValue, "type": type.rawValue, "trackids": trackid], headers: headers)
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
                            
                            let fetched = data[trackid][0]
                            if !fetched.isEmpty {
                                let version = Version(number: Global.tilde)
                                for e in 0..<fetched.count {
                                    version.links.append(Link(
                                        link: fetched[e]["link"].stringValue,
                                        cracker: fetched[e]["cracker"].stringValue,
                                        host: fetched[e]["host"].stringValue,
                                        id: fetched[e]["id"].stringValue,
                                        verified: fetched[e]["verified"].boolValue,
                                        di_compatible: fetched[e]["di_compatible"].boolValue,
                                        hidden: fetched[e]["is_hidden"] == "0" ? false : true,
                                        universal: fetched[e]["is_universal"] == "0" ? false : true
                                    ))
                                }; versions.append(version)
                            }
                        
                        } else {
                            
                            var keys: [String] = []
                            for (key, _) in data[trackid] {
                                if !data[trackid][key].isEmpty { keys.append(key) }
                            }
                            
                            keys.sort { $0.compare($1, options: .numeric) == .orderedDescending }
                            
                            for key in keys {
                                let version = Version(number: key), fetched = data[trackid][key]
                                for e in 0..<fetched.count {
                                    version.links.append(Link(
                                        link: fetched[e]["link"].stringValue,
                                        cracker: fetched[e]["cracker"].stringValue,
                                        host: fetched[e]["host"].stringValue,
                                        id: fetched[e]["id"].stringValue,
                                        verified: fetched[e]["verified"].boolValue,
                                        di_compatible: fetched[e]["di_compatible"].boolValue,
                                        hidden: fetched[e]["is_hidden"] == "0" ? false : true,
                                        universal: fetched[e]["is_universal"] == "0" ? false : true
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
    
}
