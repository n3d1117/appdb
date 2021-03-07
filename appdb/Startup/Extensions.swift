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
import DeepDiff
import SwiftTheme
import Static

// Delay function
func delay(_ delay: Double, closure: @escaping () -> Void) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

// Operator ~~ for quickly separating iphone/ipad sizes
infix operator ~~: AdditionPrecedence
func ~~ <T>(left: T, right: T) -> T { Global.isIpad ? left : right }

// MARK: - UINavigationBar
// UINavigationBar extension to hide bottom hairline. Useful for segmented control under Navigation Bar
extension UINavigationBar {
    func hideBottomHairline() {
        setValue(true, forKey: "hidesShadow")
    }
}

// MARK: - String

extension String {

    // Prettify errors
    var prettified: String {
        switch self {
        case "cancelled": return "Operation has been cancelled.".localized()
        case "MAINTENANCE_MODE": return "Maintenance mode. We will be back soon.".localized()
        case "INVALID_LINK_CODE": return "Invalid link code.".localized()
        case "INVALID_EMAIL": return "Invalid email address.".localized()
        case "NO_DEVICE_LINKED": return "No device linked.".localized()
        case "USE_LINK_CODE_INSTEAD": return "Use link code instead.".localized()
        case "MISSING_LINK_CODE_OR_EMAIL": return "Missing link code or email.".localized()
        case "PRO_EXPIRED": return "Your PRO subscription has expired.".localized()
        case "PRO_REVOKED": return "Your PRO subscription has been revoked by Apple.".localized()
        case "DEVICE_IS_NOT_PRO": return "Your device doesn't seem to have a PRO subcription.".localized()
        case "ALONGSIDE_NOT_SUPPORTED": return "App duplication is currently supported on non-jailbroken devices with PRO.".localized()
        case "The operation couldn’t be completed. ObjectMapper failed to serialize response.": return "Oops! Something went wrong. Please try again later.".localized()
        case "TOO_SHORT_SEARCH_STRING": return "Please search at least two characters".localized()
        case "NOT_READY": return "The request timed out".localized()
        case "NOT_COMPATIBLE_WITH_DEVICE": return "Your device is not compatible with this app".localized()
        case "REPORT_ALREADY_SUBMITTED": return "A report has already been submitted".localized()
        case "ERROR_PRO_REQUIRED": return "Your device needs to be PRO in order to request paid apps to be uploaded automatically.".localized()
        case "ERROR_PAID_APPS_REQUESTS_LIMIT_REACHED": return "Paid apps request limit reached. You can request up to 1 paid apps per week.".localized()
        case "ERROR_REQUEST_APPLE_APP": return "This app can not be requested, it is native iOS/iPadOS/tvOS app.".localized()
        case "ERROR_REQUEST_ONLY_IOS_APPS_SUPPORTED": return "Only iOS Apps From AppStore are supported in automatic requests.".localized()
        case "ERROR_REQUEST_STATUS_CANT_BE_SET": return "This request status can't be set.".localized()
        case "ERROR_SUCH_REQUEST_EXISTS": return "Such request already exists. But we have added you as requester as well.".localized()
        case "ERROR_SUCH_VERSION_EXISTS_AND_LINKS_AVAILABLE": return "Such version is already on appdb and it has links available.".localized()
        case "ERROR_INVALID_APPSTORE_URL": return "Invalid AppStore URL.".localized()
        case "JSON could not be serialized because of error:\nThe data couldn’t be read because it isn’t in the correct format.": return "An error has occurred: malformed JSON".localized()
        case "ERROR_UNKNOWN_VOUCHER_PARTNER": return "Unknown voucher partner.".localized()
        case "INVALID_VOUCHER": return "Invalid voucher.".localized()
        case "VOUCHER_ALREADY_USED": return "Voucher already used.".localized()
        case "NO_DEVICES_WITH_THIS_EMAIL": return "No devices with this email.".localized()
        default: return localized()
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
        var newString: String = replacingOccurrences(of: "\n", with: "")
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
            dateFormatter.locale = Locale(identifier: Localize.currentLanguage())
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
            dateFormatter.locale = Locale(identifier: Localize.currentLanguage())
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
            formatter.locale = Locale(identifier: Localize.currentLanguage())
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
            formatter.locale = Locale(identifier: Localize.currentLanguage())
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        return ""
    }

    //
    // Returns short formatted string from revocation date
    // E.G. "Revocation Time: May 30 22:03:50 2019 GMT" -> "May 31, 2019 at 12:03 AM"
    //
    var revokedDateDecoded: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d HH:mm:ss yyyy Z"
        formatter.locale = Locale(identifier: "en_US")
        var cleanedString = replacingOccurrences(of: "Revoked by Apple, Inc. \tRevocation Time: ", with: "")
        cleanedString = cleanedString.replacingOccurrences(of: "Revocation Time: ", with: "")
        cleanedString = cleanedString.replacingOccurrences(of: "  ", with: " ")
        if let date = formatter.date(from: cleanedString) {
            formatter.locale = Locale(identifier: Localize.currentLanguage())
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return ""
    }

    // Returns string without ending \n
    func trimTrailingWhitespace() -> String {
        if let trailingWs = range(of: "\\s+$", options: .regularExpression) {
            return replacingCharacters(in: trailingWs, with: "")
        } else {
            return self
        }
    }

    // Convert string to Base 64
    func toBase64() -> String {
        Data(utf8).base64EncodedString()
    }

    /// Encode URL properly (apparently `addingPercentEncoding` with `.urlHostAllowed` does not escape [&=] )
    var urlEncoded: String? {
        let set = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ")
        return self.addingPercentEncoding(withAllowedCharacters: set.inverted)
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
            line.height ~== 1 / UIScreen.main.scale
            line.left ~== line.superview!.left ~+ (full ? 0 : Global.Size.margin.value)
            line.right ~== line.superview!.right
            line.top ~== line.superview!.bottom ~- (1 / UIScreen.main.scale)
        }
    }
}

class TableViewHeader: UITableViewHeaderFooterView {
    func addSeparator(full: Bool = false) {
        let line = UIView()
        line.theme_backgroundColor = Color.borderColor
        addSubview(line)
        constrain(line) { line in
            line.height ~== 1 / UIScreen.main.scale
            line.left ~== line.superview!.left ~+ (full ? 0 : Global.Size.margin.value)
            line.right ~== line.superview!.right
            line.top ~== line.superview!.bottom ~- (1 / UIScreen.main.scale)
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let OpenSafari = Notification.Name("DidClickButtonSoPleaseOpenSafari")
    static let RefreshSettings = Notification.Name("DidUpdateLinkStateSoPleaseRefreshSettings")
    static let Deauthorized = Notification.Name("AppWasDeauthorized")
    static let UpdateQueuedSegmentTitle = Notification.Name("DidUpdateNumberOfQueuedApps")
}

// MARK: - Textfield in SearchBar

extension UISearchBar {
    var textField: UITextField? {
        let subViews = subviews.flatMap { $0.subviews }
        return subViews.first(where: { $0 is UITextField }) as? UITextField
    }
}

// MARK: - UIColor

public extension UIColor {
    var imageValue: UIImage {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(cgColor)
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
            let attrs: [NSAttributedString.Key: Any] = [.kern: value]
            attributedText = NSAttributedString(string: textString, attributes: attrs)
        }
    }
}

// MARK: - NSMutableAttributedString

extension NSMutableAttributedString {
    func setAttachmentsAlignment(_ alignment: NSTextAlignment) {
        enumerateAttribute(NSAttributedString.Key.attachment, in: NSRange(location: 0, length: length), options: .longestEffectiveRangeNotRequired) { attribute, range, _ -> Void in
            if attribute is NSTextAttachment {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = alignment
                paragraphStyle.lineBreakMode = .byTruncatingTail
                addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: range)
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

// MARK: - UITableViewCell setEnabled
extension UITableViewCell {
    func setEnabled(on: Bool) {
        isUserInteractionEnabled = on
        for view in contentView.subviews {
            view.isUserInteractionEnabled = on
            view.alpha = on ? 1 : 0.5
        }
    }
}

// MARK: - traitCollectionDidChange

extension UIViewController {
    @available(iOS 13.0, *)
    func updateAppearance(style: UIUserInterfaceStyle) {
        if Preferences.followSystemAppearance {
            switch style {
            case .light:
                if Themes.isNight {
                    Themes.switchTo(theme: .light)
                }
            default:
                if !Themes.isNight {
                    Themes.switchTo(theme: Preferences.shouldSwitchToDarkerTheme ? .darker : .dark)
                }
            }
        }
        Global.refreshAppearanceForCurrentTheme()
    }
}

extension TableViewController {
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        updateAppearance(style: traitCollection.userInterfaceStyle)
        if let self = self as? Settings {
            self.refreshSources()
        }
    }
}

extension UINavigationController {
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        updateAppearance(style: traitCollection.userInterfaceStyle)
    }
}

extension UITabBarController {
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        updateAppearance(style: traitCollection.userInterfaceStyle)
    }
}

extension UITableViewController {
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        updateAppearance(style: traitCollection.userInterfaceStyle)
        if self is ThemeChooser {
            tableView.reloadData()
        }
    }
}

extension UICollectionViewController {
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        updateAppearance(style: traitCollection.userInterfaceStyle)
    }
}

// MARK: - Glue for UITableViewCell iOS 13 background color changes
extension UITableViewCell {
    func setBackgroundColor(_ color: ThemeColorPicker) {
        if #available(iOS 13.0, *) {
            contentView.backgroundColor = nil
            contentView.isOpaque = false
        } else {
            contentView.theme_backgroundColor = color
        }
    }
}

// MARK: - UIApplication top View Controller & top Navigation View Controller

extension UIApplication {
    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }

    class func topNavigation(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UINavigationController? {
        if let nav = viewController as? UINavigationController {
            return nav
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return selected.navigationController
            }
        }
        return viewController?.navigationController
    }
}

// MARK: - URL & FileManager (credits: Nikolai Ruhe - https://stackoverflow.com/a/28660040)

extension URL {

    static let allocatedSizeResourceKeys: Set<URLResourceKey> = [
        .isRegularFileKey,
        .fileAllocatedSizeKey,
        .totalFileAllocatedSizeKey
    ]

    func regularFileAllocatedSize() throws -> UInt64 {
        let resourceValues = try self.resourceValues(forKeys: URL.allocatedSizeResourceKeys)
        guard resourceValues.isRegularFile ?? false else { return 0 }
        return UInt64(resourceValues.totalFileAllocatedSize ?? resourceValues.fileAllocatedSize ?? 0)
    }
}

extension FileManager {
    public func sizeOfDirectory(at directoryURL: URL) throws -> UInt64 {
        var enumeratorError: Error?
        func errorHandler(_: URL, error: Error) -> Bool {
            enumeratorError = error
            return false
        }
        let enumerator = self.enumerator(at: directoryURL,
                                         includingPropertiesForKeys: Array(URL.allocatedSizeResourceKeys),
                                         options: [],
                                         errorHandler: errorHandler)!
        var accumulatedSize: UInt64 = 0
        for item in enumerator {
            if enumeratorError != nil { break }
            guard let contentItemURL = item as? URL else { break }
            accumulatedSize += try contentItemURL.regularFileAllocatedSize()
        }
        if let error = enumeratorError { throw error }
        return accumulatedSize
    }
}

// MARK: - DiffAware

extension DiffAware where Self: Hashable {
    public var diffId: Int {
        hashValue
    }

    public static func compareContent(_ a: Self, _ b: Self) -> Bool {
        a == b
    }
}

extension Item: DiffAware { }
extension LocalIPAFile: DiffAware { }
