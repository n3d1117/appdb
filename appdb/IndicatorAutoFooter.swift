//
//  IndicatorAutoFooter.swift
//  SwiftPullToRefresh
//
//  Created by ned on 15/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//
//  Source: https://github.com/WXGBridgeQ/SwiftPullToRefresh

import UIKit

class IndicatorAutoFooter: RefreshView {

    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    init(height: CGFloat, action: @escaping () -> Void) {
        super.init(style: .autoFooter, height: height, action: action)
        addSubview(indicator)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        indicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }

    override func didUpdateState(_ isRefreshing: Bool) {
        isRefreshing ? indicator.startAnimating() : indicator.stopAnimating()
    }

    override func didUpdateProgress(_ progress: CGFloat) {

    }

}
