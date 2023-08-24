//
//  API+DeviceStatus.swift
//  appdb
//
//  Created by ned on 15/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

extension API {

    static func getDeviceStatus(success: @escaping (_ items: [DeviceStatusItem]) -> Void, fail: @escaping (_ error: NSError) -> Void) {
        AF.request(endpoint + Actions.getStatus.rawValue, parameters: ["lang": languageCode], headers: headersWithCookie)
            .responseArray(keyPath: "data") { (response: AFDataResponse<[DeviceStatusItem]>) in
                switch response.result {
                case .success(let results):
                    success(results)
                case .failure(let error):
                    fail(error as NSError)
                }
            }
    }

    static func emptyCommandQueue(success: @escaping () -> Void) {
        AF.request(endpoint + Actions.clear.rawValue, parameters: ["lang": languageCode], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success:
                success()
            case .failure:
                break
            }
        }
    }

    static func fixCommand(uuid: String) {
        AF.request(endpoint + Actions.fix.rawValue, parameters: ["uuid": uuid, "lang": languageCode], headers: headersWithCookie).responseJSON { _ in }
    }

    static func retryCommand(uuid: String) {
        AF.request(endpoint + Actions.retry.rawValue, parameters: ["uuid": uuid, "lang": languageCode], headers: headersWithCookie).responseJSON { _ in }
    }
}
