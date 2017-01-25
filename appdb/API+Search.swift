//
//  API+Search.swift
//  appdb
//
//  Created by ned on 11/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import RealmSwift
import SwiftyJSON

extension API {
    
    // MARK: - Search
    
    static func search <T:Object>(type: T.Type, order: Order, price: Price = .all, genre: String = "0",
                        success:@escaping (_ items: [T]) -> Void, fail:@escaping (_ error: NSError) -> Void) -> Void where T:Mappable, T:Meta {
        
        Alamofire.request(endpoint, parameters: ["action": Actions.search.rawValue, "type": T.type().rawValue, "order": order.rawValue, "price": price.rawValue, "genre": genre])
            .responseArray(keyPath: "data") { (response: DataResponse<[T]>) in
                
                switch response.result {
                case .success(let items):
                    autoreleasepool {
                        do {
                            try realm.write { realm.add(items, update: true) }
                            success(items)
                        } catch let error as NSError {
                            fail(error)
                        }
                    }
                case .failure(let error):
                    fail(error as NSError)
                }
        }
    }
}
