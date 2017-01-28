//
//  ThemeCGFloatPicker.swift
//  SwiftTheme
//
//  Created by Gesen on 2017/1/28.
//  Copyright © 2017年 Gesen. All rights reserved.
//

import UIKit

public final class ThemeCGFloatPicker: ThemePicker{
    
    public convenience init(keyPath: String) {
        self.init(v: { CGFloat(ThemeManager.numberForKeyPath(keyPath) ?? 0) })
    }
    
    public convenience init(floats: CGFloat...) {
        self.init(v: { ThemeManager.elementForArray(floats) })
    }
    
    public required convenience init(arrayLiteral elements: CGFloat...) {
        self.init(v: { ThemeManager.elementForArray(elements) })
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
    
    public class func pickerWithKeyPath(_ keyPath: String) -> ThemeCGFloatPicker {
        return ThemeCGFloatPicker(keyPath: keyPath)
    }
    
    public class func pickerWithFloats(_ floats: [CGFloat]) -> ThemeCGFloatPicker {
        return ThemeCGFloatPicker(v: { ThemeManager.elementForArray(floats) })
    }
    
}

extension ThemeCGFloatPicker: ExpressibleByArrayLiteral {}
extension ThemeCGFloatPicker: ExpressibleByStringLiteral {}
