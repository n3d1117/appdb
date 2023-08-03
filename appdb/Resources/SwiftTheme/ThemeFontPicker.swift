//
//  ThemeFontPicker.swift
//  SwiftTheme
//
//  Created by Gesen on 2017/1/28.
//  Copyright © 2017年 Gesen. All rights reserved.
//

import UIKit

@objc public final class ThemeFontPicker: ThemePicker {
    
    public convenience init(keyPath: String, map: @escaping (Any?) -> UIFont?) {
        self.init(v: { map(ThemeManager.value(for: keyPath)) })
    }
    
    public convenience init(fonts: UIFont...) {
        self.init(v: { ThemeManager.element(for: fonts) })
    }
    
    public required convenience init(arrayLiteral elements: UIFont...) {
        self.init(v: { ThemeManager.element(for: elements) })
    }
    
}

@objc public extension ThemeFontPicker {
    
    class func pickerWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> UIFont?) -> ThemeFontPicker {
        return ThemeFontPicker(v: { map(ThemeManager.value(for: keyPath)) })
    }
    
    class func pickerWithFonts(_ fonts: [UIFont]) -> ThemeFontPicker {
        return ThemeFontPicker(v: { ThemeManager.element(for: fonts) })
    }
    
}

extension ThemeFontPicker: ExpressibleByArrayLiteral {}
