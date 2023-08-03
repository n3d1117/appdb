//
//  API+Plus.swift
//  appdb
//
//  Created by stev3fvcks on 19.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {

    static func getPlusPurchaseOptions(success: @escaping (_ items: [PlusPurchaseOption]) -> Void, fail: @escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.getPlusPurchaseOptions.rawValue,
                                                 "lang": languageCode], headers: headersWithCookie)
            .responseArray(keyPath: "data") { (response: AFDataResponse<[PlusPurchaseOption]>) in
                switch response.result {
                case .success(let plusPurchaseOptions):
                    success(plusPurchaseOptions)
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }
}
