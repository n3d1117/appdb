//
//  ConfigServer.swift
//  appdb
//
//  Created by ned on 10/04/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import UIKit
import Swifter
import Alamofire
import SwiftyJSON

/**
 *
 *  A class that manages a local server used to serve a .mobilconfig file
 *
 */
class ConfigServer: NSObject {
    
    // Using callback for delegation. Neat!
    // Source: http://marinbenc.com/why-you-shouldnt-use-delegates-in-swift
    var hasCompleted: ((_ error: String?) -> ())?
    
    // Possible states
    private enum configState: Int {
        case stopped, ready, hopefullyInstalledConfig, backToApp
    }
    
    // The listening port
    internal let listeningPort: in_port_t = 8080
    
    // Local server instance
    private var localServer: HttpServer!
    
    // The .mobileconfig is passed as Data in the constructor
    private var configData: Data!
    
    // The device appdb token, used to redirect to appdb.store/?lt=token on complete
    private var token: String = ""
    
    // The current state
    private var currentState: configState = .stopped
    
    // A random 8 characters string used to serve the install page
    // Randomised so that we don't use the same page to avoid possible conflicts
    let randomString = Global.randomString(length: 8)
    
    // Background task
    private var backgroundTask = UIBackgroundTaskInvalid
    
    // Initialization
    init(configData: Data, token: String) {
        super.init()
        self.configData = configData
        self.token = token
        
        // Initialize http server
        localServer = HttpServer()
        
        // Set up page handlers
        setupHandlers()
    }
    
    // MARK: Control functions
    
    internal func start() {
        let page = composeURL(ending: "start/")
        if let url = URL(string: page), UIApplication.shared.canOpenURL(url) {
            do {
                try localServer.start(listeningPort, forceIPv4: false, priority: .default)
                currentState = .ready
                registerForNotifications()
                UIApplication.shared.openURL(url)
            } catch {
                self.stop()
            }
        }
    }
    
    internal func stop() {
        if currentState != .stopped {
            currentState = .stopped
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    private func setupHandlers() {
        
        // The '/start' page is simply used to redirect to the real, randomized page
        localServer["/start"] = { _ in
            if self.currentState == .ready {
                let page = self.redirectionHTMLPage(usesScriptToRedirect: true)
                return .ok(.html(page))
            } else {
                return .notFound
            }
        }
        
        // The randomized page
        localServer["\(randomString)"] = { _ in
            switch self.currentState {
            case .stopped:
                return .notFound
            case .ready:
                return HttpResponse.raw(200, "OK", ["Content-Type": "application/x-apple-aspen-config"], { writer in
                    do {
                        // Serve the .mobileconfig file
                        try writer.write(self.configData)
                        self.currentState = .hopefullyInstalledConfig
                    } catch {
                        print(error)
                    }
                })
            case .hopefullyInstalledConfig:
                let page = self.buttonHTMLPage()
                return .ok(.html(page))
            case .backToApp:
                let page = self.redirectionHTMLPage()
                return .ok(.html(page))
            }
        }
    }
    
    private func returnedToApp() {
        
        // Delete local mobileconfig
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let configFileUrl = documentsDirectory.appendingPathComponent("enroll.mobileconfig")
        if FileManager.default.fileExists(atPath: configFileUrl.path) {
            do {
                try FileManager.default.removeItem(at: configFileUrl)
            } catch {
                print(error)
            }
        }
        
        if currentState != .stopped {
            currentState = .stopped
            localServer.stop()
            checkSuccess()
        }
    }
    
    private func checkSuccess() {
        API.getLinkCode(success: {
            // worked! successfully got link code
            self.hasCompleted?(nil)
        }) { error in
            self.hasCompleted?(error)
        }
    }
}

// MARK: HTML stuff

extension ConfigServer {
    
    private func composeURL(ending: String?) -> String {
        var base = "http://localhost:\(listeningPort)"
        if let e = ending { base += "/\(e)" }
        return base
    }

    private func buttonHTMLPage() -> String {
        return  "<!doctype html><html>" +
                "<head><meta charset='utf-8'><title>appdb Profile Install</title></head>" +
                "<a href=\"appdb://\"><button onclick=\"setTimeout(cleanup, 5000)\">Click meeeeeeeeee</button></a>" +
                "<script>function cleanup() { window.location.href = 'https://appdb.store/?lt=\(self.token)'; }</script>" +
                "<body></body></html>"
    }

    private func redirectionHTMLPage(usesScriptToRedirect: Bool = true) -> String {
        if !usesScriptToRedirect {
            return  "<!doctype html><html>" +
                    "<head><meta charset='utf-8'><title>appdb Profile Install</title></head>" +
                    "<body></body></html>"
        } else {
            let url = composeURL(ending: randomString)
            return  "<!doctype html><html>" +
                    "<head><meta charset='utf-8'><title>appdb Profile Install</title></head>" +
                    "<script>function load() { window.location.href='\(url)'; } window.setInterval(load, 1200);</script>" +
                    "<body></body></html>"
        }
    }
}

// MARK: Background task logic

extension ConfigServer {
    
    private func registerForNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(didEnterBackground),
                                       name: .UIApplicationDidEnterBackground, object: nil)
        notificationCenter.addObserver(self, selector: #selector(willEnterForeground),
                                       name: .UIApplicationWillEnterForeground, object: nil)
    }
    
    @objc internal func didEnterBackground(notification: NSNotification) {
        if currentState != .stopped {
            startBackgroundTask()
        }
    }
    
    @objc internal func willEnterForeground(notification: NSNotification) {
        if backgroundTask != UIBackgroundTaskInvalid {
            stopBackgroundTask()
            returnedToApp()
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
        if backgroundTask != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(self.backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }
}

