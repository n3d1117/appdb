//
//  API+AltStoreRepos.swift
//  appdb
//
//  Created by stev3fvcks on 17.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {

    static func getAltStoreRepos(isPublic: Bool = false, success:@escaping (_ items: [AltStoreRepo]) -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.getAltStoreRepos.rawValue, "is_public": isPublic ? 1 : 0, "lang": languageCode], headers: headersWithCookie)
            .responseArray(keyPath: "data") { (response: AFDataResponse<[AltStoreRepo]>) in
                switch response.result {
                case .success(let results):
                    success(results)
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }
    
    static func getAltStoreRepo(id: String, success:@escaping (_ item: AltStoreRepo) -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.getAltStoreRepos.rawValue, "id": id, "lang": languageCode], headers: headersWithCookie)
            .responseArray(keyPath: "data") { (response: AFDataResponse<[AltStoreRepo]>) in
                switch response.result {
                case .success(let result):
                    if !result.isEmpty, let repo = result.first {
                        success(repo)
                    } else {
                        fail("An unknown error occurred".localized())
                    }
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }
    
    static func addAltStoreRepo(url: String, isPublic: Bool = false, success:@escaping (_ item: AltStoreRepo) -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.editAltStoreRepo.rawValue, "url": url, "is_public": isPublic ? 1 : 0, "lang": languageCode], headers: headersWithCookie)
            .responseObject(keyPath: "data") { (response: AFDataResponse<AltStoreRepo>) in
                switch response.result {
                case .success(let result):
                    success(result)
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }
    
    static func editAltStoreRepo(id: String, url: String, isPublic: Bool = false, success:@escaping (_ item: AltStoreRepo) -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.editAltStoreRepo.rawValue, "id": id, "url": url, "is_public": isPublic ? 1 : 0, "lang": languageCode], headers: headersWithCookie)
            .responseObject(keyPath: "data") { (response: AFDataResponse<AltStoreRepo>) in
                switch response.result {
                case .success(let result):
                    success(result)
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }
    
    static func deleteAltStoreRepo(id: String, success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.deleteAltStoreRepo.rawValue, "id": id, "lang": languageCode], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        fail(json["errors"][0]["translated"].stringValue)
                    } else {
                        success()
                    }
                case .failure(let error):
                    fail(error.localizedDescription)
                }
            }
    }
}
