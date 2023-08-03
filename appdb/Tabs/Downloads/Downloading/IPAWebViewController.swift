//
//  IPAWebViewController.swift
//  appdb
//
//  Created by ned on 10/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import WebKit

import Alamofire

protocol IPAWebViewControllerDelegate: AnyObject {
    func didDismiss()
}

class IPAWebViewNavController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            modalPresentationStyle = .automatic
            isModalInPresentation = true
        } else {
            modalPresentationStyle = .overFullScreen
        }
    }
}

// A Web View controller that blocks ads and is able to react to download requests for .ipa files

class IPAWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private var webView: WKWebView!
    private var progressView: UIProgressView!

    private weak var delegate: IPAWebViewControllerDelegate?

    var appIcon: String = ""
    var url: URL!

    let allowedContentTypes: Set = ["application/octet-stream", "application/x-zip", "binary/octet-stream", "application/zip", "application/binary", "application/x-ios-app", "application/x-zip-compressed", "application/x-download", "application/force-download", "application/x-itunes-ipa"]

    init(delegate: IPAWebViewControllerDelegate, url: URL, appIcon: String = "") {
        self.url = url
        self.appIcon = appIcon
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        view = webView

        // Progress view
        progressView = UIProgressView()
        progressView.trackTintColor = .clear
        progressView.theme_progressTintColor = Color.mainTint
        progressView.progress = 0
        view.addSubview(progressView)

        // Add cancel and share button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(self.dismissAnimated))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.share))

        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)

        setConstraints()

        startLoading(request: URLRequest(url: url))
    }

    deinit {
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        webView?.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
    }

    // Loads adblocker with WKContentRuleListStore if iOS >= 11
    // Otherwise just load request, ads will be blocked in decidePolicyFor:navigationAction
    private func startLoading(request: URLRequest) {
        webView.configuration.userContentController.add(self, name: "readBlob")
        if #available(iOS 11, *) {
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: "rules",
                encodedContentRuleList: blockRules) { list, error in
                    guard let list = list, error == nil else {
                        self.webView.load(request)
                        return
                    }
                    self.webView.configuration.userContentController.add(list)
                    self.webView.load(request)
            }
        } else {
            webView.load(request)
        }
    }

    // swiftlint:disable:next block_based_kvo
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.alpha = 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.2, delay: 0.7, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }, completion: { _ in
                    self.progressView.setProgress(0, animated: false)
                })
            }
        }
        if keyPath == "title" {
            title = webView.title
        }
    }

    // MARK: - Constraints

    private var group = ConstraintGroup()
    private func setConstraints() {
        constrain(progressView, replace: group) { progress in
            progress.top ~== progress.superview!.topMargin
            progress.leading ~== progress.superview!.leading
            progress.trailing ~== progress.superview!.trailing
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard self.progressView != nil else { return }
            self.setConstraints()
        }, completion: nil)
    }

    // MARK: - Dismiss animated

    @objc func dismissAnimated() { dismiss(animated: true) }

    // MARK: - Share

    @objc func share(sender: UIBarButtonItem) {
        guard let url = url else { return }
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: [SafariActivity()])
        if #available(iOS 11.0, *) {} else {
            activity.excludedActivityTypes = [.airDrop]
        }
        activity.popoverPresentationController?.barButtonItem = sender
        present(activity, animated: true)
    }
}

extension IPAWebViewController {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            guard let url = navigationAction.request.url, let host = url.host, let delegate = delegate else { return nil }

            // Do not push a new controller for known ads
            if AdBlocker.shared.shouldBlock(host: host) {
                return nil
            } else {
                let webVc = IPAWebViewController(delegate: delegate, url: url, appIcon: appIcon)
                navigationController?.pushViewController(webVc, animated: true)
            }
        }
        return nil
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // Start download
        func download(url: String, filename: String) {
            decisionHandler(.cancel)
            webView.stopLoading()
            ObserveDownloadingApps.shared.addDownload(url: url, filename: filename, icon: appIcon)
            dismissAnimated()
            delegate?.didDismiss()
        }

        if let url = navigationResponse.response.url, let filename = navigationResponse.response.suggestedFilename {
            // DEBUG
            #if DEBUG
                if filename.hasSuffix(".ipa") {
                    debugLog((navigationResponse.response as? HTTPURLResponse)?.allHeaderFields["Content-Type"] as? String ?? "")
                }
            #endif

            if let contentType = (navigationResponse.response as? HTTPURLResponse)?.allHeaderFields["Content-Type"] as? String {
                if allowedContentTypes.contains(contentType), filename.hasSuffix(".ipa") {
                    // Start download if Content-Type header field is correct and filename ends with .ipa
                    download(url: url.absoluteString, filename: filename)
                    return
                }
            } else if filename.hasSuffix(".ipa") {
                // Fallback for some servers not providing Content-Type header field (looking at you, uploadhive)
                download(url: url.absoluteString, filename: filename)
                return
            }
        }

        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if url.absoluteString.hasPrefix("itms-services://") || url.absoluteString.hasPrefix("https://itunes.apple.com") {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }

        if let scheme = url.scheme, scheme == "blob" {
            // This is MEGA blob data
            let script = """
            function blobToDataURL(blob, callback) {
                var a = new FileReader();
                a.onload = function(e) {callback(e.target.result);}
                a.readAsDataURL(blob);
            }
            document.querySelectorAll('a').forEach(async(el) => {
                const url = el.getAttribute('href');
                if( url.indexOf('blob:')===0 ) {
                    let blob = await fetch(url).then(r => r.blob());
                    blobToDataURL(blob, datauri => window.webkit.messageHandlers.readBlob.postMessage(datauri) );
                }
            });
            """
            webView.evaluateJavaScript(script, completionHandler: nil)
            decisionHandler(.cancel)
            return
        }

        guard let host = url.host else {
            decisionHandler(.cancel)
            return
        }

        // On iOS < 11 block ads the old way. On >= 11, use WKContentRuleListStore (already loaded)
        if #available(iOS 11, *) {} else {
            AdBlocker.shared.shouldBlock(host: host) ? decisionHandler(.cancel) : decisionHandler(.allow)
            return
        }

        // DEBUG
        #if DEBUG
            if !AdBlocker.shared.shouldBlock(host: host) {
                debugLog("HOST: \(host)")
            }
        #endif

        decisionHandler(.allow)
    }
}

// MARK: - WKScriptMessageHandler conformance

extension IPAWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let base64DataString = message.body as? String else { return }
        guard base64DataString.starts(with: "data:application/octet-stream;base64,") else { return }
        // Before decoding we need to drop this: "data:application/octet-stream;base64,"
        guard let dataDecoded = Data(base64Encoded: String(base64DataString.dropFirst(37))) else { return }
        let filename: String = Global.randomString(length: 15) + "-MEGA.ipa"
        let fileURL: URL = IPAFileManager.shared.documentsDirectoryURL().appendingPathComponent(filename)
        do {
            try dataDecoded.write(to: fileURL)
            dismissAnimated()
            delay(0.8) {
                Messages.shared.showSuccess(message: "File downloaded successfully, added to Library".localized())
            }
        } catch {
            debugLog(error)
        }
    }
}
