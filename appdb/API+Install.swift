//
//  API+Install.swift
//  appdb
//
//  Created by ned on 28/09/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {
    static func install(id: String, type: ItemType, completion:@escaping (_ error: String?) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.install.rawValue, "type": type.rawValue, "id": id], headers: headersWithCookie)
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
    
    static func requestInstallJB(plist: String, icon: String, link: String, completion:@escaping (_ error: String?) -> Void) {
        Alamofire.request(endpoint, method: .post, parameters: ["action": Actions.customInstall.rawValue, "plist": plist, "icon": icon, "link": link], headers: headersWithCookie)
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
