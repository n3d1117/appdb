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

    // Using callback for delegation
    var hasCompleted: ((_ error: String?) -> Void)?

    // Possible states
    private enum ConfigState: Int {
        case stopped, ready, hopefullyInstalledConfig, backToApp
    }

    // The listening port
    internal let listeningPort: in_port_t = 8080

    // Local server instance
    private var localServer: HttpServer!

    // The .mobileconfig is passed as Data in the constructor
    private var configData: Data!

    // The device appdb token, used to redirect to appdb.to/?lt=token on complete
    private var token: String = ""

    // The current state
    private var currentState: ConfigState = .stopped

    // A random 8 characters string used to serve the install page
    // Randomised so that we don't use the same page to avoid possible conflicts
    let randomString = Global.randomString(length: 8)

    // Background task
    private var backgroundTask: BackgroundTaskUtil?

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Control functions

    internal func start() {
        let page = composeURL(ending: "start/")
        if let url = URL(string: page), UIApplication.shared.canOpenURL(url) {
            do {
                try localServer.start(listeningPort, forceIPv4: false, priority: .default)
                currentState = .ready

                backgroundTask = BackgroundTaskUtil()
                backgroundTask?.start()
                backgroundTask?.afterStopClosure = { [weak self] in
                    self?.returnedToApp()
                }

                UIApplication.shared.openURL(url)
            } catch {
                self.stop()
            }
        }
    }

    internal func stop() {
        if currentState != .stopped {
            currentState = .stopped
            self.hasCompleted?("Oops! Something went wrong. Please try again later.".localized())
            backgroundTask = nil
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
                    } catch { }
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
        if currentState != .stopped {
            currentState = .stopped
            localServer.stop()
        }

        // Delete local mobileconfig
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let configFileUrl = documentsDirectory.appendingPathComponent("enroll.mobileconfig")
        if FileManager.default.fileExists(atPath: configFileUrl.path) {
            do {
                try FileManager.default.removeItem(at: configFileUrl)
            } catch { }
        }

        backgroundTask = nil

        API.getLinkCode(success: { [weak self] in
            guard let self = self else { return }
            self.hasCompleted?(nil)
        }, fail: { [weak self] error in
            guard let self = self else { return }
            self.hasCompleted?(error)
        })
    }
}

// MARK: HTML stuff

extension ConfigServer {
    private func composeURL(ending: String?) -> String {
        var base = "http://127.0.0.1:\(listeningPort)"
        if let ending = ending { base += "/\(ending)" }
        return base
    }

    private func buttonHTMLPage() -> String {
        return  "<!doctype html><html>" +
                "<head><meta charset='utf-8'><title>appdb Profile Install</title>" +
                "<style>.btn,.btn:hover{text-decoration:none}.center{width:345px;height:100px;margin:auto;position:absolute;top:0;bottom:0;left:0;right:0;max-width:100%;max-height:100%;overflow:auto}.btn{background:#62baf5;background-image:-webkit-linear-gradient(top,#62baf5,#358abf);background-image:-moz-linear-gradient(top,#62baf5,#358abf);background-image:-ms-linear-gradient(top,#62baf5,#358abf);background-image:-o-linear-gradient(top,#62baf5,#358abf);background-image:linear-gradient(to bottom,#62baf5,#358abf);-webkit-border-radius:60;-moz-border-radius:60;border-radius:60px;text-shadow:1px 1px 15px #666;color:#fff;font-size:45px;padding:15px 50px}.btn:hover{background:#1d89cc;background-image:-webkit-linear-gradient(top,#1d89cc,#3498db);background-image:-moz-linear-gradient(top,#1d89cc,#3498db);background-image:-ms-linear-gradient(top,#1d89cc,#3498db);background-image:-o-linear-gradient(top,#1d89cc,#3498db);background-image:linear-gradient(to bottom,#1d89cc,#3498db)}</style></head>" +
                "<a href=\"appdb-ios://\"><div class=\"center\"><button class=\"btn\" onclick=\"setTimeout(cleanup, 5000)\">Back to app</button></div></a>" +
                "<script>function cleanup() { window.location.href = '\(Global.mainSite)?lt=\(self.token)'; }</script>" +
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
