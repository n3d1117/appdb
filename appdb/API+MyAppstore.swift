//
//  API+MyAppstore.swift
//  appdb
//
//  Created by ned on 26/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {
    
    static func getIpas(success:@escaping (_ items: [MyAppstoreApp]) -> Void, fail:@escaping (_ error: NSError) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.getIpas.rawValue, "lang": languageCode], headers: headersWithCookie)
            .responseArray(keyPath: "data") { (response: DataResponse<[MyAppstoreApp]>) in
                
                switch response.result {
                case .success(let ipas):
                    do {
                        try realm.write { realm.add(ipas, update: true) }
                        success(ipas)
                    } catch let error as NSError {
                        fail(error)
                    }
                case .failure(let error):
                    fail(error as NSError)
                }
        }
    }
    
    static func deleteIpa(id: String, completion:@escaping (_ error: String?) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.deleteIpa.rawValue, "id": id, "lang": languageCode], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        guard !json["errors"].isEmpty else { completion("An error has occurred".localized()); return }
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
