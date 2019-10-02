//
//  AdaptiveUIAlertController.swift
//  appdb
//
//  Created by ned on 03/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Foundation
import UIKit

// An adaptive UIAlertController (iOS >= 11 && iOS < 13) that can adapt to light and dark themes
// Source: https://stackoverflow.com/a/41780021

extension UIAlertController {

    private enum AssociatedKeys {
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
        return blurStyle == .dark ? UIColor(red: 28.0 / 255.0, green: 28.0 / 255.0, blue: 28.0 / 255.0, alpha: 1.0) : nil
    }

    private var cancelActionView: UIView? {
        return view.recursiveSubviews.compactMap({ $0 as? UILabel}).first(where: { $0.text == actions.first(where: { $0.style == .cancel })?.title })?.superview?.superview
    }

    private var visualEffectView: UIVisualEffectView? {
        return view.recursiveSubviews.compactMap({$0 as? UIVisualEffectView}).first
    }

    public convenience init(title: String?, message: String?, preferredStyle: UIAlertController.Style, adaptive: Bool) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)

        if #available(iOS 13.0, *) { return }
        guard adaptive, !Global.isIpad else { return }

        let blurStyle: UIBlurEffect.Style = Themes.isNight ? .dark : .light

        if preferredStyle == .actionSheet {
            self.blurStyle = blurStyle
        } else {
            if #available(iOS 11.0, *) {
                if let title = title, blurStyle == .dark {
                    setValue(NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 19 ~~ 18)]), forKey: "attributedTitle")
                }
                if let message = message, blurStyle == .dark {
                    setValue(NSAttributedString(string: message, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14 ~~ 13)]), forKey: "attributedMessage")
                }
                self.blurStyle = blurStyle
            }
        }
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if #available(iOS 13.0, *) { return }
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
