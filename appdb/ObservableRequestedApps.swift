//
//  ObservableRequestedApp.swift
//  appdb
//
//  Created by ned on 21/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import SwiftyJSON

class ObservableRequestedApps {
    
    static var shared = ObservableRequestedApps()
    private init() { }
    
    fileprivate var requestedApps = [RequestedApp]()
    
    fileprivate var timer: Timer? = nil
    
    var onUpdate: ((_ apps: [RequestedApp]) -> ())?
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    func addApp(linkId: String, id: String, type: ItemType, name: String, image: String, bundleId: String) {
        
        var app = RequestedApp(linkId: linkId, id: id, type: type, name: name, image: image, bundleId: bundleId)
        app.status = "Waiting..." // todo localize, or remove?
        
        requestedApps.insert(app, at: 0)
        
        // Start timer
        if timer == nil {
            updateAppsStatus()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateAppsStatus), userInfo: nil, repeats: true)
        }
        
        // Increase Downloads badge
        UIApplication.shared.keyWindow?.rootViewController?.badgeAddOne(for: .downloads)
    }
    
    func removeApp(linkId: String) {
        if let index = requestedApps.firstIndex(where: { $0.linkId == linkId }) {
            requestedApps.remove(at: index)
            
            // Decrease Downloads badge
            UIApplication.shared.keyWindow?.rootViewController?.badgeSubtractOne(for: .downloads)
        }
    }
    
    func removeAllApps() {
        self.requestedApps = []
        
        // Reset badge
        UIApplication.shared.keyWindow?.rootViewController?.updateBadge(with: nil, for: .downloads)
    }
    
    func updateStatus(linkId: String, status: String) {
        if let index = requestedApps.firstIndex(where: { $0.linkId == linkId }) {
            self.requestedApps[index].status = status
        }
    }
    
    @objc func updateAppsStatus() {
        if !requestedApps.isEmpty {

            API.getDeviceStatus(success: { [unowned self] items in
                
                if items.isEmpty {
                    self.removeAllApps()
                } else {
                    for item in items.filter({ Global.isSecondsAway(from: $0.added.unixToDate) }) {
                        if item.type == "install_app" {
                            self.removeApp(linkId: item.linkId)
                        }
                        if item.type == "linked_device_info", (item.status == "new" || item.status == "ok") {
                            var newStatus: String = item.statusShort + "\n" + item.statusText
                            if newStatus == "\n" { newStatus = "Waiting..." } // todo localize
                            self.updateStatus(linkId: item.linkId, status: newStatus)
                        }
                    }
                }
                
                self.onUpdate?(self.requestedApps)

            }, fail: { _ in })

        }
    }
    
}
