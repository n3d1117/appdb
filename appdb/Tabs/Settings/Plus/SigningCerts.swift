//
//  SigningCerts.swift
//  appdb
//
//  Created by stev3fvcks on 23.08.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit
import WebKit

class SigningCerts: UIViewController {
    
    var webView: WKWebView!
    var loadingIndicator: UIActivityIndicatorView!
    var navigatedCount: Int = 0

    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        webView = WKWebView(frame: view.frame)
        webView.allowsBackForwardNavigationGestures = true

        if #available(iOS 13.0, *) {
            loadingIndicator = UIActivityIndicatorView(style: .large)
        } else {
            loadingIndicator = UIActivityIndicatorView(style: .gray)
        }

        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()

        navigationItem.title = "SigningCerts"

        webView.navigationDelegate = self
        view.addSubview(webView)

        view.addSubview(loadingIndicator)

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false

        view.addConstraints([
            NSLayoutConstraint(item: loadingIndicator!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: loadingIndicator!, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView!, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
        ])
        
        loadWebView()
    }

    func loadWebView() {
        API.getUDID { udid in
            do {
                let request = try URLRequest(url: URL(string: Global.signingCertsEmbedUrl + "&udid=\(udid)&email=\(Preferences.email)")!, method: .get)
                self.webView.load(request)
            } catch {
                Messages.shared.showError(message: error.localizedDescription)
            }
        } fail: { error in
            Messages.shared.showError(message: error)
        }
    }

    @objc func dismissAnimated() {
        dismiss(animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension SigningCerts: WKNavigationDelegate {
    
    @available(iOS 14.5, *)
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        self.loadingIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loadingIndicator.stopAnimating()
        if navigatedCount > 0 {
            UIApplication.shared.open(webView.url!)
            dismissAnimated()
        } else {
            navigatedCount += 1
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Messages.shared.showError(message: error.localizedDescription)
        dismissAnimated()
    }
}
