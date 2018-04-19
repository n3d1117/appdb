//
//  API+DeviceLink.swift
//  appdb
//
//  Created by ned on 10/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {
    
    static func linkDevice(code: String, success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
        
        Alamofire.request(endpoint, parameters: ["action": Actions.link.rawValue, "type": "control", "link_code": code,
                                                 "lang": languageCode], headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        guard !json["errors"].isEmpty else { return }
                        fail(json["errors"][0].stringValue)
                    } else {
                        do {
                            // Save token
                            guard let pref = realm.objects(Preferences.self).first else { return }
                            try realm.write { pref.token = json["data"]["link_token"].stringValue }
                            
                            // Update link code
                            self.getLinkCode(success: {
                                 success()
                            }, fail: { error in
                                fail(error)
                            })
                            
                        } catch let error as NSError {
                            fail(error.localizedDescription)
                        }
                    }
                case .failure(let error):
                    fail(error.localizedDescription)
                }
        }
    }
    
    static func linkNewDevice(email: String, success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
    
        Alamofire.request(endpoint, parameters: ["action": Actions.link.rawValue, "type": "new", "email": email,
                                                 "lang": languageCode], headers: headers)
        .responseJSON { response in

            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                if !json["success"].boolValue {
                    guard !json["errors"].isEmpty else { return }
                    fail(json["errors"][0].stringValue)
                } else {
                    
                    let profile_service = json["data"]["profile_service"].stringValue
                    let token = json["data"]["link_token"].stringValue
                    
                    guard !token.isEmpty else { fail("Unable to fetch device token.".localized()); return }
                    
                    // Save token
                    do {
                        guard let pref = realm.objects(Preferences.self).first else { return }
                        try realm.write { pref.token = token }
                    } catch let error as NSError {
                        fail(error.localizedDescription)
                    }
                    
                    // If profile_service is empty, device is already authorized
                    guard !profile_service.isEmpty else {
                        API.getLinkCode(success: {
                            success()
                        }) { error in
                            fail(error)
                        }
                        return
                    }
                    
                    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
                        let fileURL = documentsURL.appendingPathComponent("enroll.mobileconfig")
                        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                    }
                    
                    // Download the mobileconfig file
                    Alamofire.download(profile_service, to: destination).responseData { response in
                        switch response.result {
                        case .success(let value):
                            
                            // Start http server
                            // Also saves link code on success
                            let server = ConfigServer(configData: value, token: token)
                            server.start()
                            server.hasCompleted = { error in
                                if let error = error { fail(error) }
                                else { success() }
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
    
    static func getLinkCode(success:@escaping () -> Void, fail:@escaping (_ error: String) -> Void) {
        
        Alamofire.request(endpoint, parameters: ["action": Actions.getLinkCode.rawValue,
                                                 "lang": languageCode], headers: headersWithCookie)
        .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if !json["success"].boolValue {
                    guard !json["errors"].isEmpty else { fail("An error has occurred".localized()); return }
                    fail(json["errors"][0].stringValue)
                } else {
                    do {
                        guard let pref = realm.objects(Preferences.self).first else { return }
                        try realm.write { pref.linkCode = json["data"].stringValue }
                        success()
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
