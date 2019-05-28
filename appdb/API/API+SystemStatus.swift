//
//  API+SystemStatus.swift
//  appdb
//
//  Created by ned on 05/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {

    static func getSystemStatus(success:@escaping (_ items: [ServiceStatus]) -> Void, fail:@escaping (_ error: NSError) -> Void) {
        Alamofire.request(statusEndpoint, headers: headers)
            .responseArray(keyPath: "data") { (response: DataResponse<[ServiceStatus]>) in
                switch response.result {
                case .success(let results):
                    success(results)
                case .failure(let error):
                    fail(error as NSError)
                }
            }
    }

    static func getLastSystemStatusUpdateTime(success:@escaping (_ checkedAt: String) -> Void) {
        Alamofire.request(statusEndpoint, headers: headers)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                success(json["checked_at"].stringValue.rfc2822decoded)
            case .failure:
                break
            }
        }
    }
}
