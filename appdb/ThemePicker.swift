//
//  ThemePicker.swift
//  SwiftTheme
//
//  Created by Gesen on 16/1/25.
//  Copyright © 2016年 Gesen. All rights reserved.
//

import UIKit

open class ThemePicker: NSObject, NSCopying {
    
    public typealias ValueType = () -> Any?
    
    var value: ValueType
    
    required public init(v: @escaping ValueType) {
        value = v
    }
    
    open func copy(with zone: NSZone?) -> Any {
        return type(of: self).init(v: value)
    }
    
}

open class ThemeColorPicker: ThemePicker, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
    
    public convenience init(keyPath: String) {
        self.init(v: { return ThemeManager.colorForKeyPath(keyPath) })
    }

    public convenience init(colors: String...) {
        self.init(v: { return ThemeManager.colorForArray(colors) })
    }
    
    public required convenience init(arrayLiteral elements: String...) {
        self.init(v: { return ThemeManager.colorForArray(elements) })
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
    
    open class func pickerWithKeyPath(_ keyPath: String) -> ThemeColorPicker {
        return ThemeColorPicker(keyPath: keyPath)
    }
    
    open class func pickerWithColors(_ colors: [String]) -> ThemeColorPicker {
        return ThemeColorPicker(v: { return ThemeManager.colorForArray(colors) })
    }
    
}

open class ThemeImagePicker: ThemePicker, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
    
    public convenience init(keyPath: String) {
        self.init(v: { return ThemeManager.imageForKeyPath(keyPath) })
    }
    
    public convenience init(names: String...) {
        self.init(v: { return ThemeManager.imageForArray(names) })
    }
    
    public convenience init(images: UIImage...) {
        self.init(v: { return ThemeManager.elementForArray(images) })
    }
    
    public required convenience init(arrayLiteral elements: String...) {
        self.init(v: { return ThemeManager.imageForArray(elements) })
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
    
    open class func pickerWithKeyPath(_ keyPath: String) -> ThemeImagePicker {
        return ThemeImagePicker(keyPath: keyPath)
    }
    
    open class func pickerWithNames(_ names: [String]) -> ThemeImagePicker {
        return ThemeImagePicker(v: { return ThemeManager.imageForArray(names) })
    }
    
    open class func pickerWithImages(_ images: [UIImage]) -> ThemeImagePicker {
        return ThemeImagePicker(v: { return ThemeManager.elementForArray(images) })
    }
    
}

open class ThemeCGFloatPicker: ThemePicker, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
    
    public convenience init(keyPath: String) {
        self.init(v: { return CGFloat(ThemeManager.numberForKeyPath(keyPath) ?? 0) })
    }
    
    public convenience init(floats: CGFloat...) {
        self.init(v: { return ThemeManager.elementForArray(floats) })
    }
    
    public required convenience init(arrayLiteral elements: CGFloat...) {
        self.init(v: { return ThemeManager.elementForArray(elements) })
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
    
    open class func pickerWithKeyPath(_ keyPath: String) -> ThemeCGFloatPicker {
        return ThemeCGFloatPicker(keyPath: keyPath)
    }
    
    open class func pickerWithFloats(_ floats: [CGFloat]) -> ThemeCGFloatPicker {
        return ThemeCGFloatPicker(v: { return ThemeManager.elementForArray(floats) })
    }
    
}

open class ThemeCGColorPicker: ThemePicker, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
    
    public convenience init(keyPath: String) {
        self.init(v: { return ThemeManager.colorForKeyPath(keyPath)?.cgColor })
    }
    
    public convenience init(colors: String...) {
        self.init(v: { return ThemeManager.colorForArray(colors)?.cgColor })
    }
    
    public required convenience init(arrayLiteral elements: String...) {
        self.init(v: { return ThemeManager.colorForArray(elements)?.cgColor })
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
    
    open class func pickerWithKeyPath(_ keyPath: String) -> ThemeCGColorPicker {
        return ThemeCGColorPicker(keyPath: keyPath)
    }
    
    open class func pickerWithColors(_ colors: [String]) -> ThemeCGColorPicker {
        return ThemeCGColorPicker(v: { return ThemeManager.colorForArray(colors)?.cgColor })
    }
    
}

open class ThemeDictionaryPicker: ThemePicker, ExpressibleByArrayLiteral {
    
    public convenience init(dicts: [String: AnyObject]...) {
        self.init(v: { return ThemeManager.elementForArray(dicts) })
    }
    
    public required convenience init(arrayLiteral elements: [String: AnyObject]...) {
        self.init(v: { return ThemeManager.elementForArray(elements) })
    }
    
    open class func pickerWithDicts(_ dicts: [[String: AnyObject]]) -> ThemeDictionaryPicker {
        return ThemeDictionaryPicker(v: { return ThemeManager.elementForArray(dicts) })
    }
    
}

open class ThemeStatusBarStylePicker: ThemePicker, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
    
    var styles: [UIStatusBarStyle]?
    var animated = true
    
    public convenience init(keyPath: String) {
        self.init(v: { return ThemeManager.stringForKeyPath(keyPath) })
    }
    
    public convenience init(styles: UIStatusBarStyle...) {
        self.init(v: { return 0 })
        self.styles = styles
    }
    
    public required convenience init(arrayLiteral elements: UIStatusBarStyle...) {
        self.init(v: { return 0 })
        self.styles = elements
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
    
    open class func pickerWithKeyPath(_ keyPath: String) -> ThemeStatusBarStylePicker {
        return ThemeStatusBarStylePicker(keyPath: keyPath)
    }
    
    open class func pickerWithStyles(_ styles: [UIStatusBarStyle]) -> ThemeStatusBarStylePicker {
        let picker = ThemeStatusBarStylePicker(v: { return 0 })
        picker.styles = styles
        return picker
    }
    
    open class func pickerWithStringStyles(_ styles: [String]) -> ThemeStatusBarStylePicker {
        return ThemeStatusBarStylePicker(v: { return ThemeManager.elementForArray(styles) })
    }
    
    func currentStyle(_ value: AnyObject?) -> UIStatusBarStyle {
        if let styles = styles {
            if styles.indices ~= ThemeManager.currentThemeIndex {
                return styles[ThemeManager.currentThemeIndex]
            }
        }
        if let styleString = value as? String {
            switch styleString {
            case "UIStatusBarStyleDefault"      : return .default
            case "UIStatusBarStyleLightContent" : return .lightContent
            default: break
            }
        }
        return .default
    }
    
}

class ThemeStatePicker: ThemePicker {
    
    typealias ValuesType = [UInt: ThemePicker]
    
    var values = ValuesType()
    
    convenience init?(picker: ThemePicker?, withState state: UIControlState) {
        guard let picker = picker else { return nil}
        
        self.init(v: { return 0 })
        values[state.rawValue] = picker
    }
    
    func setPicker(_ picker: ThemePicker?, forState state: UIControlState) -> Self {
        values[state.rawValue] = picker
        return self
    }
}
