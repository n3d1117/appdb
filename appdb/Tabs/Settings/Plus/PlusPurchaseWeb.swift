//
//  PlusPurchaseWeb.swift
//  appdb
//
//  Created by stev3fvcks on 19.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit
import WebKit

class PlusPurchaseWeb: UIViewController {
    
    var webView: WKWebView!
    var loadingIndicator: UIActivityIndicatorView!
    var formHtml: String!
    var navigatedCount: Int = 0
    var submittedForm: Bool = false

    init(with purchaseOption: PlusPurchaseOption) {
        formHtml = "<html><body>\(purchaseOption.html)<script>document.querySelector(\"form\").submit()</script></body></html>"
        
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        webView = WKWebView(frame: view.frame)
        webView.allowsBackForwardNavigationGestures = true
        
        
        if #available(iOS 13.0, *) {
            loadingIndicator = UIActivityIndicatorView(style: .large)
        } else {
            loadingIndicator = UIActivityIndicatorView(style: .gray)
        }
        
        loadingIndicator.startAnimating()
                
        navigationItem.title = purchaseOption.name
                        
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
    }
    
    func loadWebView() {
        webView.loadHTMLString(formHtml, baseURL: nil)
    }
    
    @objc func dismissAnimated() -> Void {
        dismiss(animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension PlusPurchaseWeb: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        navigatedCount += 1
        if submittedForm {
            if loadingIndicator != nil {
                loadingIndicator.removeFromSuperview()
                loadingIndicator = nil
            }
        } else if navigatedCount > 1 {
            submittedForm = true
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Messages.shared.showError(message: error.localizedDescription)
        dismissAnimated()
    }
}

