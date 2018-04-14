//
//  API+News.swift
//  appdb
//
//  Created by ned on 15/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//


import Alamofire

extension API {
    
    static func getNews(limit: Int = 10,
                        success:@escaping (_ items: [SingleNews]) -> Void,
                        fail:@escaping (_ error: NSError) -> Void) {
        
        Alamofire.request(endpoint, parameters: ["action": Actions.getNews.rawValue, "lang": languageCode, "limit": String(limit)], headers: headers)
            .responseArray(keyPath: "data") { (response: DataResponse<[SingleNews]>) in
                
                switch response.result {
                case .success(let news):
                    do {
                        try realm.write { realm.add(news, update: true) }
                        success(news)
                    } catch let error as NSError {
                        fail(error)
                    }
                case .failure(let error):
                    fail(error as NSError)
                }
        }
    }
    
    static func getNewsDetail(id: String, success:@escaping (_ item: SingleNews) -> Void, fail:@escaping (_ error: NSError) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.getNews.rawValue, "lang": languageCode, "id": id], headers: headers)
        .responseObject(keyPath: "data") { (response: DataResponse<SingleNews>) in
            switch response.result {
            case .success(let singleNews):
                do {
                    try realm.write { realm.add(singleNews, update: true) }
                    success(singleNews)
                } catch let error as NSError {
                    fail(error)
                }
            case .failure(let error):
                fail(error as NSError)
            }
        }
    }
    
}
