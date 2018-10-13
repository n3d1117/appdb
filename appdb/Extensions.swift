//
//  Extensions.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//


import UIKit
import Cartography
import Kanna
import Localize_Swift

// Delay function
func delay(_ delay: Double, closure: @escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

// Operator ~~ for quickly separating iphone/ipad sizes
infix operator ~~ : AdditionPrecedence
func ~~<T>(left: T, right: T) -> T { return IS_IPAD ? left : right }

// MARK: - UINavigationBar
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

// MARK: - String

extension String {
    
    // Prettify errors
    var prettified: String {
        switch self {
        case "MAINTENANCE_MODE": return "Maintenance mode. We will be back soon.".localized()
        case "INVALID_LINK_CODE": return "Invalid link code.".localized()
        case "INVALID_EMAIL": return "Invalid email address.".localized()
        case "NO_DEVICE_LINKED": return "No device linked.".localized()
        case "USE_LINK_CODE_INSTEAD": return "Use link code instead.".localized()
        case "MISSING_LINK_CODE_OR_EMAIL": return "Missing link code or email.".localized()
        case "The operation couldn’t be completed. ObjectMapper failed to serialize response.": return "Oops! Something went wrong. Please try again later.".localized()
        case "TOO_SHORT_SEARCH_STRING": return "Please search at least two characters".localized()
        default: return self
        }
    }
    
    //
    // Decode from HTML using Kanna and keep new line
    //
    // regex from http://buildregex.com
    // matches <br />, <br/> and <p/>
    //
    var decoded: String {
        let regex = "(?:(?:(?:\\<br\\ \\/\\>))|(?:(?:\\<br\\/\\>))|(?:(?:\\<p\\/\\>)))"
        let newString: String =  self.replacingOccurrences(of: regex, with: "\n", options: .regularExpression, range: nil)
        do {
            return try HTML(html: newString, encoding: .utf8).text ?? ""
        } catch {
            return ""
        }
    }
    
    //
    // Returns string date from unix time
    //
    var unixToString: String {
        if let unixTime = Double(self) {
            let date = Date(timeIntervalSince1970: unixTime)
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    //
    // Returns date from unix time
    //
    var unixToDate: Date {
        if let unixTime = Double(self) {
            return Date(timeIntervalSince1970: unixTime)
        }
        return Date()
    }
    
    //
    // Returns detailed string date from unix time
    //
    var unixToDetailedString: String {
        if let unixTime = Double(self) {
            let date = Date(timeIntervalSince1970: unixTime)
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .medium
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    //
    // Returns formatted string from rfc2822 date
    // E.G. "Sat, 05 May 2018 13:42:01 -0400" -> "May 5, 2018 at 10.07 PM"
    //
    var rfc2822decoded: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC 2822
        formatter.locale = Locale(identifier: "en_US")
        if let date = formatter.date(from: self) {
            formatter.locale = NSLocale.current
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return ""
    }
    
    //
    // Returns short formatted string from rfc2822 date
    // E.G. "Sat, 05 May 2018 13:42:01 -0400" -> "May 5, 2018"
    //
    var rfc2822decodedShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z" // RFC 2822
        formatter.locale = Locale(identifier: "en_US")
        if let date = formatter.date(from: self) {
            formatter.locale = NSLocale.current
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        return ""
    }
    
    // Returns string without ending \n
    func trimTrailingWhitespace() -> String {
        if let trailingWs = self.range(of: "\\s+$", options: .regularExpression) {
            return self.replacingCharacters(in: trailingWs, with: "")
        } else {
            return self
        }
    }
    
}

// MARK: - Separators

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

// MARK: - Emoji

// FUCK EMOJIS
extension Character {
    fileprivate func isEmoji() -> Bool {
        return Character(UnicodeScalar(UInt32(0x1d000))!) <= self && self <= Character(UnicodeScalar(UInt32(0x1f77f))!)
            || Character(UnicodeScalar(UInt32(0x2100))!) <= self && self <= Character(UnicodeScalar(UInt32(0x26ff))!)
    }
}

extension String {
    var removedEmoji: String {
        return String(self.filter { !$0.isEmoji() })
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let OpenSafari = Notification.Name("DidClickButtonSoPleaseOpenSafari")
    static let RefreshSettings = Notification.Name("DidUpdateLinkStateSoPleaseRefreshSettings")
}

// MARK: - Textfield in SearchBar

extension UISearchBar {
    var textField: UITextField? {
        for subview in subviews.first?.subviews ?? [] {
            if let textField = subview as? UITextField {
                return textField
            }
        }
        return nil
    }
}

// MARK: - UIColor

public extension UIColor {
    public var imageValue: UIImage {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(self.cgColor)
        context.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
