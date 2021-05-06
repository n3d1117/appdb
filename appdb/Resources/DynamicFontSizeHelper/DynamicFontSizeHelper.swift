// DynamicFontSizeHelper.swift by KelvinJin

import UIKit

private var fontSizeMultiplier : CGFloat {
    switch UIApplication.shared.preferredContentSizeCategory {
    case .accessibilityExtraExtraExtraLarge:  return 19 / 16
    case .accessibilityExtraExtraLarge:       return 19 / 16
    case .accessibilityExtraLarge:            return 19 / 16
    case .accessibilityLarge:                 return 19 / 16
    case .accessibilityMedium:                return 19 / 16
    case .extraExtraExtraLarge:               return 19 / 16
    case .extraExtraLarge:                    return 19 / 16
    case .extraLarge:                         return 18 / 16
    case .large:                              return 17 / 16
    case .medium:                             return 1.0
    case .small:                              return 15 / 16
    case .extraSmall:                         return 14 / 16
    default: return 1.0
    }
}

private class ContentSizeCategoryChangeManager {
    static let sharedInstance = ContentSizeCategoryChangeManager()
    
    typealias ContentSizeCategoryDidChangeCallback = () -> Void
    
    class Observer {
        weak var object: AnyObject?
        var block: ContentSizeCategoryDidChangeCallback
        
        init(object: AnyObject, block: @escaping ContentSizeCategoryDidChangeCallback) {
            self.object = object
            self.block = block
        }
    }
    
    fileprivate var observerPool: [Observer] = []
    
    fileprivate init() {
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryDidChange(_:)), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    func addCallback(_ observer: AnyObject, block: @escaping ContentSizeCategoryDidChangeCallback) {
        // Don't re-add the call back.
        guard !observerPool.contains(where: { $0.object === observer }) else { return }
        
        // Run the block once to make sure the font size is initialized correctly.
        block()
        
        observerPool.append(Observer(object: observer, block: block))
    }
    
    @objc func contentSizeCategoryDidChange(_ notification: Notification) {
        DispatchQueue.main.async { [unowned self] in
            self.observerPool = self.observerPool.filter { $0.object != nil }
            self.observerPool.forEach { $0.block() }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

protocol FontSizeScalable: AnyObject {
    var scalableFont: UIFont { get set }
}

extension FontSizeScalable {
    fileprivate func registerForSizeChange(_ defaultFontSize: CGFloat? = nil) {
        let defaultFontSize = defaultFontSize ?? scalableFont.pointSize
        
        ContentSizeCategoryChangeManager.sharedInstance.addCallback(self) { [weak self] in
            guard let _self = self else { return }
            _self.scalableFont = UIFont(descriptor: _self.scalableFont.fontDescriptor, size: defaultFontSize * fontSizeMultiplier)
        }
    }
}

extension UILabel: FontSizeScalable {
    
    func makeDynamicFont() { registerForSizeChange(self.font.pointSize) }
    
    var scalableFont: UIFont {
        get { return self.font }
        set { self.font = newValue }
    }
}

extension UIButton: FontSizeScalable {
    
    func makeDynamicFont() { registerForSizeChange(self.titleLabel?.font.pointSize) }
    
    var scalableFont: UIFont {
        get { return self.titleLabel?.font ?? UIFont() }
        set { self.titleLabel?.font = newValue }
    }
}
