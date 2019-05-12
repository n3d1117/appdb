//
//  ObserveQueuedApps.swift
//  appdb
//
//  Created by ned on 21/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import SwiftyJSON

class ObserveQueuedApps {
    
    static var shared = ObserveQueuedApps()
    private init() { }
    
    fileprivate var requestedApps = [RequestedApp]()
    fileprivate var timer: Timer?
    fileprivate var numberOfQueuedApps: Int = 0
    
    var onUpdate: ((_ apps: [RequestedApp]) -> ())?
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    func addApp(type: ItemType, linkId: String, name: String, image: String, bundleId: String) {
        
        let app = RequestedApp(type: type, linkId: linkId, name: name, image: image, bundleId: bundleId)
        requestedApps.insert(app, at: 0)
        
        // Start timer
        if timer == nil {
            updateAppsStatus()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateAppsStatus), userInfo: nil, repeats: true)
        }
        
        // Increase Downloads badge
        UIApplication.shared.keyWindow?.rootViewController?.badgeAddOne(for: .downloads)
        
        // Notify updates
        numberOfQueuedApps += 1
        let numberOfQueuedAppsDict: [String: Int] = ["number": numberOfQueuedApps, "tab": 0]
        NotificationCenter.default.post(name: .UpdateQueuedSegmentTitle, object: self, userInfo: numberOfQueuedAppsDict)
    }
    
    func removeApp(linkId: String) {
        if let index = requestedApps.firstIndex(where: { $0.linkId == linkId }) {
            requestedApps.remove(at: index)
            
            // Decrease Downloads badge
            UIApplication.shared.keyWindow?.rootViewController?.badgeSubtractOne(for: .downloads)
            
            numberOfQueuedApps -= 1
            let numberOfQueuedAppsDict: [String: Int] = ["number": numberOfQueuedApps, "tab": 0]
            NotificationCenter.default.post(name: .UpdateQueuedSegmentTitle, object: self, userInfo: numberOfQueuedAppsDict)
        }
    }
    
    func removeAllApps() {
        self.requestedApps = []
        
        // Reset badge
        UIApplication.shared.keyWindow?.rootViewController?.updateBadge(with: nil, for: .downloads)
        
        numberOfQueuedApps = 0
        let numberOfQueuedAppsDict: [String: Int] = ["number": numberOfQueuedApps, "tab": 0]
        NotificationCenter.default.post(name: .UpdateQueuedSegmentTitle, object: self, userInfo: numberOfQueuedAppsDict)
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
                    let linkIds = self.requestedApps.map{ $0.linkId }
                    for item in items.filter({ linkIds.contains($0.linkId) }) {
                        
                        // Remove app if install prompted
                        if item.type == "install_app" {
                            // todo handle failed_fixable
                            self.removeApp(linkId: item.linkId)
                        }
                        
                        // Track status progress
                        if item.type == "linked_device_info" {
                            if item.statusShort == "failed" {
                                Messages.shared.showError(message: item.statusText)
                                self.removeApp(linkId: item.linkId)
                            } else {
                                var newStatus: String = item.statusShort + "\n" + item.statusText
                                if newStatus == "\n" { newStatus = "Waiting...".localized() }
                                self.updateStatus(linkId: item.linkId, status: newStatus)
                            }
                        }
                        
                        // Should books be supported?
                    }
                }
                
                self.onUpdate?(self.requestedApps)

            }, fail: { _ in })

        }
    }
    
}
