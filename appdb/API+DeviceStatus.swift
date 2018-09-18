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
        
        Alamofire.request(endpoint, parameters: ["action": Actions.getStatus.rawValue,
                                                 "lang": languageCode], headers: headersWithCookie)
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
        Alamofire.request(endpoint, parameters: ["action": Actions.clear.rawValue, "lang": languageCode], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
                case .success(_):
                    success()
                case .failure:
                    break
            }
        }
        
    }
    
}
