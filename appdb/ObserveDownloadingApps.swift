//
//  ObserveDownloadingApps.swift
//  appdb
//
//  Created by ned on 09/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import SwiftyJSON

class ObserveDownloadingApps {
    
    static var shared = ObserveDownloadingApps()
    private init() { }
    
    var apps = [DownloadingApp]()
    
    fileprivate var numberOfDownloadingApps: Int = 0
    
    var onAdded: ((_ app: DownloadingApp) -> ())?
    var onRemoved: ((_ app: DownloadingApp) -> ())?

    func addDownload(url: String, filename: String, icon: String) {

        var app: DownloadingApp?
        
        API.downloadIPA(url: url, request: { r in
            
            let util = LocalIPADownloadUtil(r)
            app = DownloadingApp(filename: filename, icon: icon, util: util)
            self.apps.insert(app!, at: 0)
            self.onAdded?(app!)
            
            // Increase Downloads badge
            UIApplication.shared.keyWindow?.rootViewController?.badgeAddOne(for: .downloads)
            
            // Notify updates
            self.numberOfDownloadingApps += 1
            let numberOfDownloadingAppsDict: [String: Int] = ["number": self.numberOfDownloadingApps, "tab": 2]
            NotificationCenter.default.post(name: .UpdateQueuedSegmentTitle, object: self, userInfo: numberOfDownloadingAppsDict)

        }) { error in
            if let error = error {
                Messages.shared.showError(message: error.prettified)
            } else {
                Messages.shared.showSuccess(message: "File downloaded successfully, added to Library") // todo localize
            }
            if let app = app, let index = self.apps.firstIndex(of: app) {
                self.apps.remove(at: index)
                self.onRemoved?(app)
                self.removeDownload()
            }
        }
    }
    
    func removeDownload() {

        // Decrease Downloads badge
        UIApplication.shared.keyWindow?.rootViewController?.badgeSubtractOne(for: .downloads)
        
        // Notify updates
        numberOfDownloadingApps -= 1
        let numberOfDownloadingAppsDict: [String: Int] = ["number": numberOfDownloadingApps, "tab": 2]
        NotificationCenter.default.post(name: .UpdateQueuedSegmentTitle, object: self, userInfo: numberOfDownloadingAppsDict)
    }

}
