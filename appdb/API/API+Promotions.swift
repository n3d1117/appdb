//
//  API+Promotions.swift
//  appdb
//
//  Created by ned on 26/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Alamofire

extension API {

    static func getPromotions(success: @escaping (_ items: [Promotion]) -> Void, fail: @escaping (_ error: NSError) -> Void) {
        AF.request(endpoint + Actions.promotions.rawValue, parameters: ["lang": languageCode], headers: headers)
            .responseArray(keyPath: "data") { (response: AFDataResponse<[Promotion]>) in
                switch response.result {
                case .success(let promotions):
                    success(promotions)
                case .failure(let error):
                    fail(error as NSError)
                }
            }
    }
}
