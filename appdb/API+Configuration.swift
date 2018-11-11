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
                        Alamofire.request(endpoint, parameters: ["action": Actions.checkRevoke.rawValue], headers: headersWithCookie)
                            .responseJSON { r in
                                switch r.result {
                                case .success(let v):
                                    let json2 = JSON(v)
                                    
                                    do {
                                        guard let pref = realm.objects(Preferences.self).first else { return }
                                        let data = json["data"]
                                        try realm.write {
                                            pref.appsync = data["appsync"].stringValue=="yes"
                                            pref.ignoreCompatibility = data["ignore_compatibility"].stringValue=="yes"
                                            pref.askForInstallationOptions = data["ask_for_installation_options"].stringValue=="yes"
                                            pref.pro = data["is_pro"].stringValue=="yes"
                                            pref.proDisabled = data["is_pro_disabled"].stringValue=="yes"
                                            pref.proRevoked = !json2["success"].boolValue
                                            pref.proRevokedOn = json2["data"].stringValue
                                            pref.proUntil = data["pro_till"].stringValue
                                            
                                            success()
                                        }
                                    } catch(let error as NSError) {
                                        fail(error.localizedDescription)
                                    }
                                    
                                case .failure(let error):
                                    fail(error.localizedDescription)
                                }
                                
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
                        // Update values
                        do {
                            guard let pref = realm.objects(Preferences.self).first else { return }
                            try realm.write {
                                for (key, value) in params {
                                    switch key {
                                    case .appsync: pref.appsync = value == "yes"
                                    case .askForOptions: pref.askForInstallationOptions = value == "yes"
                                    case .ignoreCompatibility: pref.ignoreCompatibility = value == "yes"
                                    }
                                }
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
    
}
