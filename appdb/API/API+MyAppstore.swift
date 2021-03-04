//
//  API+MyAppStore.swift
//  appdb
//
//  Created by ned on 26/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {

    static func getIpas(success:@escaping (_ items: [MyAppStoreApp]) -> Void, fail:@escaping (_ error: NSError) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.getIpas.rawValue, "lang": languageCode], headers: headersWithCookie)
            .responseArray(keyPath: "data") { (response: AFDataResponse<[MyAppStoreApp]>) in
                switch response.result {
                case .success(let ipas):
                    success(ipas)
                case .failure(let error as NSError):
                    fail(error)
                }
            }
    }

    static func deleteIpa(id: String, completion:@escaping (_ error: String?) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.deleteIpa.rawValue, "id": id, "lang": languageCode], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    if !json["success"].boolValue {
                        completion(json["errors"][0].stringValue)
                    } else {
                        completion(nil)
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
    }

    static func addToMyAppStore(jobId: String, fileURL: URL, request:@escaping (_ r: Alamofire.UploadRequest) -> Void, completion:@escaping (_ error: String?) -> Void) {
        let parameters = [
            "action": Actions.addIpa.rawValue,
            "job_id": jobId
        ]

        request(AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(fileURL, withName: "ipa")
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: endpoint, method: .post, headers: headersWithCookie).responseJSON { response in

            switch response.result {
            case .success(let value):
                let json = JSON(value)
                if !json["success"].boolValue {
                    completion(json["errors"][0].stringValue)
                } else {
                    completion(nil)
                }
            case .failure(let error):
                completion(error.localizedDescription)
            }
        })
    }

    static func analyzeJob(jobId: String, completion:@escaping (_ error: String?) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.analyzeIpa.rawValue], headers: headersWithCookie)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)

                    if !json["success"].boolValue {
                        completion(json["errors"][0].stringValue)
                    } else {
                        for i in 0..<json["data"].count {
                            let job = json["data"][i]
                            if job["id"].stringValue == jobId {
                                if job["status"].stringValue.contains("Success") {
                                    completion(nil)
                                } else {
                                    completion(job["status"].stringValue)
                                }
                                break
                            }
                        }
                    }
                case .failure(let error):
                    completion(error.localizedDescription)
                }
            }
    }

    static func downloadIPA(url: String, request:@escaping (_ r: DownloadRequest) -> Void, completion:@escaping (_ error: String?) -> Void) {
        guard let url = URL(string: url) else { return }

        let destination: DownloadRequest.Destination = { _, response in
            let filename: String = response.suggestedFilename ?? (Global.randomString(length: 10) + ".ipa")
            var fileURL: URL = IPAFileManager.shared.documentsDirectoryURL().appendingPathComponent(filename)
            var i: Int = 0
            while FileManager.default.fileExists(atPath: fileURL.path) {
                i += 1
                let newName = String(filename.dropLast(4)) + " (\(i)).\(url.pathExtension)"
                fileURL = IPAFileManager.shared.documentsDirectoryURL().appendingPathComponent(newName)
            }
            return (fileURL, [])
        }

        let download = AF.download(url, to: destination)
        request(download)

        download.response { response in
            if let error = response.error {
                completion(error.localizedDescription)
            } else {
                completion(nil)
            }
        }
    }
}
