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
func ~~<T>(left: T, right: T) -> T { return Global.isIpad ? left : right }

// MARK: - UINavigationBar
// UINavigationBar extension to hide bottom hairline. Useful for segmented control under Navigation Bar
extension UINavigationBar {
    func hideBottomHairline() {
        self.setValue(true, forKey: "hidesShadow")
    }
}

// MARK: - String

extension String {
    
    // Prettify errors
    var prettified: String {
        switch self {
        case "cancelled": return "Operation has been cancelled.".localized() // todo localize
        case "MAINTENANCE_MODE": return "Maintenance mode. We will be back soon.".localized()
        case "INVALID_LINK_CODE": return "Invalid link code.".localized()
        case "INVALID_EMAIL": return "Invalid email address.".localized()
        case "NO_DEVICE_LINKED": return "No device linked.".localized()
        case "USE_LINK_CODE_INSTEAD": return "Use link code instead.".localized()
        case "MISSING_LINK_CODE_OR_EMAIL": return "Missing link code or email.".localized()
        case "The operation couldn’t be completed. ObjectMapper failed to serialize response.": return "Oops! Something went wrong. Please try again later.".localized()
        case "TOO_SHORT_SEARCH_STRING": return "Please search at least two characters".localized()
        case "NOT_READY": return "The request timed out".localized()
        case "NOT_COMPATIBLE_WITH_DEVICE": return "Your device is not compatible with this app".localized() // todo localize
        default: return self.localized()
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
        var newString: String = self.replacingOccurrences(of: "\n", with: "")
        newString = newString.replacingOccurrences(of: regex, with: "\n", options: .regularExpression)
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
    
    // Convert string to Base 64
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
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
    static let UpdateQueuedSegmentTitle = Notification.Name("DidUpdateNumberOfQueuedApps")
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
    var imageValue: UIImage {
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

// MARK: - UILabel

extension UILabel {
    func addCharactersSpacing(_ value: CGFloat = 1.15) {
        if let textString = text {
            let attrs: [NSAttributedString.Key : Any] = [.kern: value]
            attributedText = NSAttributedString(string: textString, attributes: attrs)
        }
    }
}

// MARK: - NSMutableAttributedString

extension NSMutableAttributedString {
    func setAttachmentsAlignment(_ alignment: NSTextAlignment) {
        self.enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: self.length), options: .longestEffectiveRangeNotRequired) { (attribute, range, stop) -> Void in
            if attribute is NSTextAttachment {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = alignment
                paragraphStyle.lineBreakMode = .byTruncatingTail
                self.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
            }
        }
    }
}

// MARK: - NSTextAttachment

extension NSTextAttachment {
    func setImageWidth(width: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: width, height: width / ratio)
    }
}
