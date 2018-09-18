//
//  API+Search.swift
//  appdb
//
//  Created by ned on 11/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import Alamofire
import RealmSwift
import SwiftyJSON
import ObjectMapper

extension API {
    
    // MARK: - Search
    
    static func search <T:Object>(type: T.Type,
                                  order: Order = .all,
                                  price: Price = .all,
                                  genre: String = "0",
                                  dev: String = "0",
                                  trackid: String = "0",
                                  q: String = "",
                                  page: Int = 0,
                                  success:@escaping (_ items: [T]) -> Void,
                                  fail:@escaping (_ error: String) -> Void) where T:Mappable, T:Meta {
        
        var shouldContinue: Bool = true
        
        Alamofire.request(endpoint, parameters: ["action": Actions.search.rawValue,
                                                 "type": T.type().rawValue,
                                                 "order": order.rawValue,
                                                 "price": price.rawValue,
                                                 "genre": genre,
                                                 "dev": dev,
                                                 "trackid": trackid,
                                                 "q": q,
                                                 "page": page,
                                                 "lang": languageCode], headers: headers)
            
            // todo speed this up and get rid of 'shouldContinue'
            
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
    
    static func fastSearch(type: ItemType, query: String, maxResults: Int = 8,
                                     success:@escaping (_ results: [String]) -> Void,
                                     fail:@escaping (_ error: String) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.search.rawValue,
                                                 "type": type.rawValue,
                                                 "order": Order.all.rawValue,
                                                 "q": query,
                                                 "lang": languageCode,
                                                 "perpage": maxResults], headers: headers)
            
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    let data = json["data"]
                    var results: [String] = []
                    let max = data.count > maxResults ? maxResults : data.count
                    for i in 0..<max { results.append(data[i]["name"].stringValue) }
                    success(results)
                } else {
                    fail("")
                }
            }
    }

}
