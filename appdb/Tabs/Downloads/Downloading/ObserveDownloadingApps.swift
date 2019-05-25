//
//  ObserveDownloadingApps.swift
//  appdb
//
//  Created by ned on 09/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

// Singleton to manage downloading apps
// TL;DR Starts download with passed data on addDownload(), updates badges
// Provides an open local array of downloading apps 
// Also provides two callback (onAdded and onRemoved) that a View Controller can subscribe to

class ObserveDownloadingApps {
    static var shared = ObserveDownloadingApps()
    private init() { }

    private var downloadBackgroundTask: BackgroundTaskUtil?

    var apps = [DownloadingApp]()

    private var numberOfDownloadingApps: Int = 0

    var onAdded: ((_ app: DownloadingApp) -> Void)?
    var onRemoved: ((_ app: DownloadingApp) -> Void)?

    func addDownload(url: String, filename: String, icon: String) {
        var app: DownloadingApp?

        downloadBackgroundTask = BackgroundTaskUtil()
        downloadBackgroundTask?.start()

        API.downloadIPA(url: url, request: { [weak self] request in
            guard let self = self else { return }

            let util = LocalIPADownloadUtil(request)
            app = DownloadingApp(filename: filename, icon: icon, util: util)
            self.apps.insert(app!, at: 0)
            self.onAdded?(app!)

            // Increase Downloads badge
            UIApplication.shared.keyWindow?.rootViewController?.badgeAddOne(for: .downloads)

            // Notify updates
            self.numberOfDownloadingApps += 1
            let numberOfDownloadingAppsDict: [String: Int] = ["number": self.numberOfDownloadingApps, "tab": 2]
            NotificationCenter.default.post(name: .UpdateQueuedSegmentTitle, object: self, userInfo: numberOfDownloadingAppsDict)
        }, completion: { error in
            self.downloadBackgroundTask = nil

            if let error = error {
                Messages.shared.showError(message: error.prettified)
            } else {
                Messages.shared.showSuccess(message: "File downloaded successfully, added to Library".localized())
            }

            if let app = app, let index = self.apps.firstIndex(of: app) {
                self.apps.remove(at: index)
                self.onRemoved?(app)
                self.removeDownload()
            }
        })
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
