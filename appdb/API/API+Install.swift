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

    static func install(id: String, type: ItemType, additionalOptions: [AdditionalInstallationParameters: Any] = [:], completion:@escaping (_ error: String?) -> Void) {
        var parameters: [String: Any] = ["action": Actions.install.rawValue, "type": type.rawValue, "id": id, "lang": languageCode]
        for (key, value) in additionalOptions { parameters[key.rawValue] = value }

        AF.request(endpoint, parameters: parameters, headers: headersWithCookie)
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

    static func requestInstallJB(plist: String, icon: String, link: String, completion:@escaping (_ error: String?) -> Void) {
        AF.request(endpoint, method: .post, parameters: ["action": Actions.customInstall.rawValue, "plist": plist, "icon": icon, "link": link, "lang": languageCode], headers: headersWithCookie)
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

    static func getPlistFromItmsHelper(bundleId: String, localIpaUrlString: String, title: String, completion:@escaping (_ plistUrl: String?) -> Void) {
        let urlString = itmsHelperEndpoint + "?i=%20&b=\(bundleId)&l=\(localIpaUrlString)&n=\(title)"
        completion(urlString.urlEncoded)
    }
}
