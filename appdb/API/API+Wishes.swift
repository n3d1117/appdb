//
//  API+Wishes.swift
//  appdb
//
//  Created by ned on 07/07/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {

    static func createPublishRequest(appStoreUrl: String, type: String = "ios", completion:@escaping (_ error: String?) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.createPublishRequest.rawValue, "url": appStoreUrl, "type": type], headers: headersWithCookie)
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

    static func getPublishRequests(includeAll: Bool, page: Int = 1, success:@escaping (_ items: [WishApp]) -> Void, fail:@escaping (_ error: String) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.getPublishRequests.rawValue, "type": "ios", "include_all": includeAll ? 1 : 0, "page": page], headers: headers)
            .responseArray(keyPath: "data") { (response: DataResponse<[WishApp]>) in
                switch response.result {
                case .success(let results):
                    success(results)
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }
}
