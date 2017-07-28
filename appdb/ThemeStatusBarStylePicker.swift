//
//  ThemeStatusBarStylePicker.swift
//  SwiftTheme
//
//  Created by Gesen on 2017/1/28.
//  Copyright © 2017年 Gesen. All rights reserved.
//

import UIKit

public final class ThemeStatusBarStylePicker: ThemePicker {
    
    var animated = true
    
    public convenience init(keyPath: String) {
        self.init(v: { ThemeStatusBarStylePicker.getStyle(stringStyle: ThemeManager.string(for: keyPath) ?? "") })
    }
    
    public convenience init(keyPath: String, map: @escaping (Any?) -> UIStatusBarStyle?) {
        self.init(v: { map(ThemeManager.value(for: keyPath)) })
    }
    
    public convenience init(styles: UIStatusBarStyle...) {
        self.init(v: { ThemeManager.element(for: styles) })
    }
    
    public required convenience init(arrayLiteral elements: UIStatusBarStyle...) {
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
    
    public class func pickerWithKeyPath(_ keyPath: String) -> ThemeStatusBarStylePicker {
        return ThemeStatusBarStylePicker(keyPath: keyPath)
    }
    
    public class func pickerWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIStatusBarStyle?) -> ThemeStatusBarStylePicker {
        return ThemeStatusBarStylePicker(v: { map(ThemeManager.value(for: keyPath)) })
    }
    
    public class func pickerWithStyles(_ styles: [UIStatusBarStyle]) -> ThemeStatusBarStylePicker {
        return ThemeStatusBarStylePicker(v: { ThemeManager.element(for: styles) })
    }
    
    public class func pickerWithStringStyles(_ styles: [String]) -> ThemeStatusBarStylePicker {
        return ThemeStatusBarStylePicker(v: { ThemeManager.element(for: styles.map(getStyle)) })
    }
    
    class func getStyle(stringStyle: String) -> UIStatusBarStyle {
        switch stringStyle.lowercased() {
        case "default"      : return .default
        case "lightcontent" : return .lightContent
        default: return .default
        }
    }
    
}

extension ThemeStatusBarStylePicker: ExpressibleByArrayLiteral {}
extension ThemeStatusBarStylePicker: ExpressibleByStringLiteral {}
