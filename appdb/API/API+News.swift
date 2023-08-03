//
//  API+News.swift
//  appdb
//
//  Created by ned on 15/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Alamofire

extension API {

    static func getNews(limit: Int = 10, success: @escaping (_ items: [SingleNews]) -> Void, fail: @escaping (_ error: NSError) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.getPages.rawValue, "category": Actions.newsCategory.rawValue, "lang": languageCode, "length": String(limit)], headers: headers)
            .responseArray(keyPath: "data") { (response: AFDataResponse<[SingleNews]>) in
                switch response.result {
                case .success(let news):
                    success(news)
                case .failure(let error):
                    fail(error as NSError)
                }
            }
    }

    static func getNewsDetail(id: String, success: @escaping (_ item: SingleNews) -> Void, fail: @escaping (_ error: NSError) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.getPages.rawValue, "category": Actions.newsCategory.rawValue, "lang": languageCode, "id": id], headers: headers)
        .responseObject(keyPath: "data") { (response: AFDataResponse<SingleNews>) in
            switch response.result {
            case .success(let singleNews):
                success(singleNews)
            case .failure(let error):
                fail(error as NSError)
            }
        }
    }
}
