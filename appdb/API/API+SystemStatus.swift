//
//  API+SystemStatus.swift
//  appdb
//
//  Created by ned on 05/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension API {

    static func getSystemStatus(success: @escaping (_ checkedAt: String, _ items: [ServiceStatus]) -> Void, fail: @escaping (_ error: NSError) -> Void) {
        var checkedAt: String!
        AF.request(statusEndpoint, headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    checkedAt = JSON(value)["checked_at"].stringValue.unixToString
                case .failure(let error):
                    fail(error as NSError)
                    return
                }
            }
            .responseArray(keyPath: "data") { (response: AFDataResponse<[ServiceStatus]>) in
                switch response.result {
                case .success(let results):
                    success(checkedAt, results)
                case .failure(let error):
                    fail(error as NSError)
                }
            }
    }
}
