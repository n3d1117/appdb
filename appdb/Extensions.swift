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
extension UIImageView {
    func cornerRadius(fromWidth: CGFloat) -> CGFloat {
        return (27 * fromWidth) / 120
    }
}

// Size label properly to fit its height
extension UILabel {
    func sizeToFitHeight() {
        let size : CGSize = self.sizeThatFits(CGSize(width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        self.frame.size.height = size.height
    }
}

//
// Operator ~~ for quickly separating iphone/ipad sizes
//
// e.g 180 ~~ 150
//
// will be 180 for iPad size, 150 for iPhone size.
//
infix operator ~~ : AdditionPrecedence
func ~~<T>(left: T, right: T) -> T {
    return IS_IPAD ? left : right
}
