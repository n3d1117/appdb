//
//  Extensions.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit

// Common corner radius (ios app icon)
func cornerRadius(fromWidth: CGFloat) -> CGFloat { return (fromWidth / 4.2) /* around 23% */ }

// Delay function
func delay(_ delay : Double, closure: @escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

// Operator ~~ for quickly separating iphone/ipad sizes
infix operator ~~ : AdditionPrecedence
func ~~<T>(left: T, right: T) -> T { return IS_IPAD ? left : right }

// UINavigationBar extension to hide/show bottom hairline. Useful for segmented control under Navigation Bar
extension UINavigationBar {
    
    func hideBottomHairline() {
        if let navigationBarImageView = hairlineImageViewInNavigationBar(view: self) {
            navigationBarImageView.isHidden = true
        }
    }
    
    func showBottomHairline() {
        if let navigationBarImageView = hairlineImageViewInNavigationBar(view: self) {
            navigationBarImageView.isHidden = false
        }
    }
    
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.height <= 1.0 { return (view as! UIImageView) }
        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(view: subview) { return imageView }
        }
        return nil
    }    
}

// Prettify errors
extension String {
    func prettified() -> String {
        switch self {
            case "MAINTENANCE_MODE": return "Maintenance mode. We will be back soon.".localized()
            default: return self
        }
    }
}
