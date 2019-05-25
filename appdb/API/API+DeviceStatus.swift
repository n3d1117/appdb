//
//  API+DeviceStatus.swift
//  appdb
//
//  Created by ned on 15/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {
    
    static func getDeviceStatus(success:@escaping (_ items: [DeviceStatusItem]) -> Void, fail:@escaping (_ error: NSError) -> Void) {
        
        Alamofire.request(endpoint, parameters: ["action": Actions.getStatus.rawValue, "lang": languageCode], headers: headersWithCookie)
            .responseArray(keyPath: "data") { (response: DataResponse<[DeviceStatusItem]>) in
                switch response.result {
                    case .success(let results):
                        success(results)
                    case .failure(let error):
                        fail(error as NSError)
                }
        }
    }
    
    static func emptyCommandQueue(success:@escaping () -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.clear.rawValue], headers: headersWithCookie)
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
        Alamofire.request(endpoint, parameters: ["action": Actions.fix.rawValue, "uuid": uuid], headers: headersWithCookie).responseJSON { _ in }
    }
    
    static func retryCommand(uuid: String) {
        Alamofire.request(endpoint, parameters: ["action": Actions.retry.rawValue, "uuid": uuid], headers: headersWithCookie).responseJSON { _ in }
    }
    
}
