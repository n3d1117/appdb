//
//  API+Search.swift
//  appdb
//
//  Created by ned on 11/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import SwiftyJSON

extension API {
    
    // MARK: - Search
    
    static func search <T:Object>(type: T.Type, order: Order = .all, price: Price = .all, genre: String = "0", trackid: String = "0",
                        success:@escaping (_ items: [T]) -> Void, fail:@escaping (_ error: String) -> Void) where T:Mappable, T:Meta {
        var shouldContinue: Bool = true
        
        Alamofire.request(endpoint, parameters: ["action": Actions.search.rawValue, "type": T.type().rawValue, "order": order.rawValue, "price": price.rawValue, "genre": genre, "trackid": trackid, "lang": languageCode], headers: headers)
            
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    if !json["success"].boolValue, !json["errors"].isEmpty {
                        fail(json["errors"][0].stringValue); shouldContinue = false
                    }
                }
            }
            
            .responseArray(keyPath: "data") { (response: DataResponse<[T]>) in
                if shouldContinue { switch response.result {
                    case .success(let items):
                        do {
                            try realm.write { realm.add(items, update: true) }
                            success(items)
                        } catch let error as NSError {
                            fail(error.localizedDescription)
                        }
                    case .failure(let error):
                        fail(error.localizedDescription)
                } }
            }
    }
}
