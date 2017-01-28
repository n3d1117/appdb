//
//  ThemeImagePicker.swift
//  SwiftTheme
//
//  Created by Gesen on 2017/1/28.
//  Copyright © 2017年 Gesen. All rights reserved.
//

import UIKit

public final class ThemeImagePicker: ThemePicker {
    
    public convenience init(keyPath: String) {
        self.init(v: { ThemeManager.imageForKeyPath(keyPath) })
    }
    
    public convenience init(names: String...) {
        self.init(v: { ThemeManager.imageForArray(names) })
    }
    
    public convenience init(images: UIImage...) {
        self.init(v: { ThemeManager.elementForArray(images) })
    }
    
    public required convenience init(arrayLiteral elements: String...) {
        self.init(v: { ThemeManager.imageForArray(elements) })
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
    
    public class func pickerWithKeyPath(_ keyPath: String) -> ThemeImagePicker {
        return ThemeImagePicker(keyPath: keyPath)
    }
    
    public class func pickerWithNames(_ names: [String]) -> ThemeImagePicker {
        return ThemeImagePicker(v: { ThemeManager.imageForArray(names) })
    }
    
    public class func pickerWithImages(_ images: [UIImage]) -> ThemeImagePicker {
        return ThemeImagePicker(v: { ThemeManager.elementForArray(images) })
    }
    
}

extension ThemeImagePicker: ExpressibleByArrayLiteral {}
extension ThemeImagePicker: ExpressibleByStringLiteral {}
