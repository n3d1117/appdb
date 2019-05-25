//
//  AdaptiveUIAlertController.swift
//  appdb
//
//  Created by ned on 03/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Foundation
import UIKit

// An adaptive UIAlertController that can adapt to light and dark themes
// Source: https://stackoverflow.com/a/41780021

extension UIAlertController {
    
    private struct AssociatedKeys {
        static var blurStyleKey = "UIAlertController.blurStyleKey"
    }
    
    public var blurStyle: UIBlurEffect.Style {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.blurStyleKey) as? UIBlurEffect.Style ?? .extraLight
        } set (style) {
            objc_setAssociatedObject(self, &AssociatedKeys.blurStyleKey, style, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    public var cancelButtonColor: UIColor? {
        return blurStyle == .dark ? UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 28.0/255.0, alpha: 1.0) : nil
    }
    
    private var cancelActionView: UIView? {
        return view.recursiveSubviews.compactMap({ $0 as? UILabel}).first(where: { $0.text == actions.first(where: { $0.style == .cancel })?.title })?.superview?.superview
    }
    
    private var visualEffectView: UIVisualEffectView? {
        return view.recursiveSubviews.compactMap({$0 as? UIVisualEffectView}).first
    }
    
    public convenience init(title: String?, message: String?, preferredStyle: UIAlertController.Style, blurStyle: UIBlurEffect.Style) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        if !Global.isIpad {
            self.blurStyle = blurStyle
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !Global.isIpad {
            visualEffectView?.effect = UIBlurEffect(style: blurStyle)
            cancelActionView?.backgroundColor = cancelButtonColor
        }
    }
}

extension UIView {
    var recursiveSubviews: [UIView] {
        var subviews = self.subviews.compactMap({$0})
        subviews.forEach { subviews.append(contentsOf: $0.recursiveSubviews) }
        return subviews
    }
}
