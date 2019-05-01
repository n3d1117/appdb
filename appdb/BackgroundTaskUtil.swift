//
//  BackgroundTaskUtil.swift
//  appdb
//
//  Created by ned on 30/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit

class BackgroundTaskUtil {
    
    fileprivate var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    var afterStopClosure: (() -> ())?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func start() {
        registerForNotifications()
    }
    
    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground),
                                       name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                       name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc fileprivate func didEnterBackground(notification: NSNotification) {
        startBackgroundTask()
    }
    
    @objc fileprivate func willEnterForeground(notification: NSNotification) {
        if backgroundTask != .invalid {
            stopBackgroundTask()
        }
    }
    
    fileprivate func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            DispatchQueue.main.async {
                self.stopBackgroundTask()
            }
        })
    }
    
    fileprivate func stopBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
            self.afterStopClosure?()
        }
    }
    
}
