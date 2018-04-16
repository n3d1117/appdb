//
//  API+Configuration.swift
//  appdb
//
//  Created by ned on 14/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {
    
    static func getConfiguration(success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
        Alamofire.request(endpoint, parameters: ["action": Actions.getConfiguration.rawValue,
                                                 "lang": languageCode], headers: headersWithCookie)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        guard !json["errors"].isEmpty else { return }
                        fail(json["errors"][0].stringValue)
                    } else {
                        do {
                            guard let pref = realm.objects(Preferences.self).first else { return }
                            let data = json["data"]
                            try realm.write {
                                pref.appsync = data["appsync"].stringValue=="yes"
                                pref.ignoreCompatibility = data["ignore_compatibility"].stringValue=="yes"
                                pref.askForInstallationOptions = data["ask_for_installation_options"].stringValue=="yes"
                                pref.pro = data["is_pro"].stringValue=="yes"
                                pref.proUntil = data["pro_till"].stringValue
                                
                                print(pref)
                                
                                success()
                            }
                        } catch let error as NSError {
                            fail(error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    fail(error.localizedDescription)
                }
        }
    }
    
    static func setConfiguration(params: [ConfigurationParameters: String], success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
        
        var parameters: [String: Any] = ["action": Actions.configure.rawValue, "lang": languageCode]
        for (key, value) in params { parameters[key.rawValue] = value }

        Alamofire.request(endpoint, parameters: parameters, headers: headersWithCookie)
            .responseJSON { response in

                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        guard !json["errors"].isEmpty else { return }
                        fail(json["errors"][0].stringValue)
                    } else {
                        success()
                    }
                case .failure(let error):
                    fail(error.localizedDescription)
                }
        }
    }
    
}
