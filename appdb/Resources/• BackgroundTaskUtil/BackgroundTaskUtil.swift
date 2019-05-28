//
//  BackgroundTaskUtil.swift
//  appdb
//
//  Created by ned on 30/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit

/*
*   TL;DR A Singleton that wraps a UIBackgroundTask, used to continue download/upload operations even after app is closed
*   Usage:
*           let b: BackgroundTaskUtil?  = BackgroundTaskUtil()
*           b?.start()
*   later..
*           b = nil
*
*   Also provides an optional callback (afterStopClosure) after background task has stopped
*/

class BackgroundTaskUtil {
    
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    var afterStopClosure: (() -> Void)?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func start() {
        registerForNotifications()
    }

    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground),
                                       name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground),
                                       name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc private func didEnterBackground(notification: NSNotification) {
        startBackgroundTask()
    }

    @objc private func willEnterForeground(notification: NSNotification) {
        if backgroundTask != .invalid {
            stopBackgroundTask()
        }
    }

    private func startBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            DispatchQueue.main.async {
                self.stopBackgroundTask()
            }
        })
    }

    private func stopBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
            self.afterStopClosure?()
        }
    }
}
