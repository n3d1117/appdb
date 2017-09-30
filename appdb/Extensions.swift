//
//  Extensions.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography
import Kanna

// Delay function
func delay(_ delay: Double, closure: @escaping ()->()) {
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
    var prettified: String {
        switch self {
            case "MAINTENANCE_MODE": return "Maintenance mode. We will be back soon.".localized()
            default: return self
        }
    }
}

extension String {
    
    //
    // Decode from HTML using Kanna and keep new line
    //
    // regex from http://buildregex.com
    // matches <br />, <br/> and <p/>
    //
    var decoded: String {
        let regex = "(?:(?:(?:\\<br\\ \\/\\>))|(?:(?:\\<br\\/\\>))|(?:(?:\\<p\\/\\>)))"
        let newString: String =  self.replacingOccurrences(of: regex, with: "\n", options: .regularExpression, range: nil)
        return HTML(html: newString, encoding: .utf8)?.text ?? ""
    }
    
    //
    // Returns string date from unix time
    //
    var unixToString: String {
        if let unixTime = Double(self) {
            let date = Date(timeIntervalSince1970: unixTime)
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: Localize.currentLanguage())
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: date)
        }
        return ""
    }
}

// Add self made separator (Thanks, Apple...)
extension DetailsCell {
    func addSeparator(full: Bool = false) {
        let line = UIView()
        line.theme_backgroundColor = Color.borderColor
        addSubview(line)
        constrain(line) { line in
            line.height == 1/UIScreen.main.scale
            line.left == line.superview!.left + (full ? 0 : Global.size.margin.value)
            line.right == line.superview!.right
            line.top == line.superview!.bottom - 1/UIScreen.main.scale
        }
    }
}
class TableViewHeader: UITableViewHeaderFooterView {
    func addSeparator(full: Bool = false) {
        let line = UIView()
        line.theme_backgroundColor = Color.borderColor
        addSubview(line)
        constrain(line) { line in
            line.height == 1/UIScreen.main.scale
            line.left == line.superview!.left + (full ? 0 : Global.size.margin.value)
            line.right == line.superview!.right
            line.top == line.superview!.bottom - 1/UIScreen.main.scale
        }
    }
}

// FUCK EMOJIS
extension Character {
    fileprivate func isEmoji() -> Bool {
        return Character(UnicodeScalar(UInt32(0x1d000))!) <= self && self <= Character(UnicodeScalar(UInt32(0x1f77f))!)
            || Character(UnicodeScalar(UInt32(0x2100))!) <= self && self <= Character(UnicodeScalar(UInt32(0x26ff))!)
    }
}

extension String {
    var removedEmoji: String {
        return String(self.characters.filter { !$0.isEmoji() })
    }
}
