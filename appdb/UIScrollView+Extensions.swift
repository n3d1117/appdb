//
//  UIScrollView+Extensions.swift
//  SwiftPullToRefresh
//
//  Created by ned on 15/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//
//  Source: https://github.com/WXGBridgeQ/SwiftPullToRefresh

import UIKit

private var headerKey: UInt8 = 0
private var footerKey: UInt8 = 0
private var tempFooterKey: UInt8 = 0

public extension UIScrollView {

    private var spr_header: RefreshView? {
        get {
            return objc_getAssociatedObject(self, &headerKey) as? RefreshView
        }
        set {
            spr_header?.removeFromSuperview()
            objc_setAssociatedObject(self, &headerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue.map { insertSubview($0, at: 0) }
        }
    }

    private var spr_footer: RefreshView? {
        get {
            return objc_getAssociatedObject(self, &footerKey) as? RefreshView
        }
        set {
            spr_footer?.removeFromSuperview()
            objc_setAssociatedObject(self, &footerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue.map { insertSubview($0, at: 0) }
        }
    }

    private var spr_tempFooter: RefreshView? {
        get {
            return objc_getAssociatedObject(self, &tempFooterKey) as? RefreshView
        }
        set {
            objc_setAssociatedObject(self, &tempFooterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    /// Indicator header
    ///
    /// - Parameters:
    ///   - height: refresh view height and also the trigger requirement, default is 60
    ///   - action: refresh action
    func spr_setIndicatorHeader(height: CGFloat = 60,
                                       action: @escaping () -> Void) {
        spr_header = IndicatorView(isHeader: true, height: height, action: action)
    }

    /// Custom header
    /// Inherit from RefreshView
    /// Update the presentation in 'didUpdateState(_:)' and 'didUpdateProgress(_:)' methods
    ///
    /// - Parameter header: your custom header inherited from RefreshView
    func spr_setCustomHeader(_ header: RefreshView) {
        self.spr_header = header
    }

    /// Custom footer
    /// Inherit from RefreshView
    /// Update the presentation in 'didUpdateState(_:)' and 'didUpdateProgress(_:)' methods
    ///
    /// - Parameter footer: your custom footer inherited from RefreshView
    func spr_setCustomFooter(_ footer: RefreshView) {
        self.spr_footer = footer
    }

    /// Begin refreshing with header
    func spr_beginRefreshing() {
        spr_header?.beginRefreshing()
    }

    /// End refreshing with both header and footer
    func spr_endRefreshing() {
        spr_header?.endRefreshing()
        spr_footer?.endRefreshing()
    }

    /// End refreshing with footer and remove it
    func spr_endRefreshingWithNoMoreData() {
        spr_tempFooter = spr_footer
        spr_footer?.endRefreshing { [weak self] in
            self?.spr_footer = nil
        }
    }
    
    /// End refreshing with header and remove it
    func spr_endRefreshingAll() {
        spr_header?.endRefreshing { [weak self] in
            self?.spr_header = nil
        }
    }

    /// Reset footer which is set to no more data
    func spr_resetNoMoreData() {
        if spr_footer == nil {
            spr_footer = spr_tempFooter
        }
    }

    /// Indicator footer
    ///
    /// - Parameters:
    ///   - height: refresh view height and also the trigger requirement, default is 60
    ///   - action: refresh action
    func spr_setIndicatorFooter(height: CGFloat = 60,
                                       action: @escaping () -> Void) {
        spr_footer = IndicatorView(isHeader: false, height: height, action: action)
    }
}
