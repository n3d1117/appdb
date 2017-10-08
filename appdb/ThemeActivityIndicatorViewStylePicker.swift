//
//  ThemeActivityIndicatorViewStylePicker.swift
//  SwiftTheme
//
//  Created by Gesen on 2017/1/28.
//  Copyright © 2017年 Gesen. All rights reserved.
//

import UIKit

@objc public final class ThemeActivityIndicatorViewStylePicker: ThemePicker {
    
    public convenience init(keyPath: String) {
        self.init(v: { ThemeActivityIndicatorViewStylePicker.getStyle(stringStyle: ThemeManager.string(for: keyPath) ?? "") })
    }
    
    public convenience init(keyPath: String, map: @escaping (Any?) -> UIActivityIndicatorViewStyle?) {
        self.init(v: { map(ThemeManager.value(for: keyPath)) })
    }
    
    public convenience init(styles: UIActivityIndicatorViewStyle...) {
        self.init(v: { ThemeManager.element(for: styles) })
    }
    
    public required convenience init(arrayLiteral elements: UIActivityIndicatorViewStyle...) {
        self.init(v: { ThemeManager.element(for: elements) })
    }
    
    public required convenience init(stringLiteral value: String) {
        self.init(keyPath: value)
    }
    
    public required convenience init(unicodeScalarLiteral value: String) {
        self.init(keyPath: value)
    }
    
    public required convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(keyPath: value)
    }
    
    class func getStyle(stringStyle: String) -> UIActivityIndicatorViewStyle {
        switch stringStyle.lowercased() {
        case "gray"         : return .gray
        case "white"        : return .white
        case "whitelarge"   : return .whiteLarge
        default: return .gray
        }
    }
    
}

public extension ThemeActivityIndicatorViewStylePicker {
    
    class func pickerWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIActivityIndicatorViewStyle?) -> ThemeActivityIndicatorViewStylePicker {
        return ThemeActivityIndicatorViewStylePicker(v: { map(ThemeManager.value(for: keyPath)) })
    }
    
    class func pickerWithStyles(_ styles: [UIActivityIndicatorViewStyle]) -> ThemeActivityIndicatorViewStylePicker {
        return ThemeActivityIndicatorViewStylePicker(v: { ThemeManager.element(for: styles) })
    }
    
}

@objc public extension ThemeActivityIndicatorViewStylePicker {
    
    class func pickerWithKeyPath(_ keyPath: String) -> ThemeActivityIndicatorViewStylePicker {
        return ThemeActivityIndicatorViewStylePicker(keyPath: keyPath)
    }
    
    class func pickerWithStringStyles(_ styles: [String]) -> ThemeActivityIndicatorViewStylePicker {
        return ThemeActivityIndicatorViewStylePicker(v: { ThemeManager.element(for: styles.map(getStyle)) })
    }
    
}

extension ThemeActivityIndicatorViewStylePicker: ExpressibleByArrayLiteral {}
extension ThemeActivityIndicatorViewStylePicker: ExpressibleByStringLiteral {}
