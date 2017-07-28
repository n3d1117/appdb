//
//  ThemeDictionaryPicker.swift
//  SwiftTheme
//
//  Created by Gesen on 2017/1/28.
//  Copyright © 2017年 Gesen. All rights reserved.
//

import Foundation

public final class ThemeDictionaryPicker: ThemePicker {
    
    public convenience init(keyPath: String, map: @escaping (Any?) -> [String: AnyObject]?) {
        self.init(v: { map(ThemeManager.value(for: keyPath)) })
    }
    
    public convenience init(dicts: [String: AnyObject]...) {
        self.init(v: { ThemeManager.element(for: dicts) })
    }
    
    public required convenience init(arrayLiteral elements: [String: AnyObject]...) {
        self.init(v: { ThemeManager.element(for: elements) })
    }
    
    public class func pickerWithKeyPath(_ keyPath: String, map: @escaping (Any?) -> [String: AnyObject]?) -> ThemeDictionaryPicker {
        return ThemeDictionaryPicker(v: { map(ThemeManager.value(for: keyPath)) })
    }
    
    public class func pickerWithDicts(_ dicts: [[String: AnyObject]]) -> ThemeDictionaryPicker {
        return ThemeDictionaryPicker(v: { ThemeManager.element(for: dicts) })
    }
    
}

extension ThemeDictionaryPicker: ExpressibleByArrayLiteral {}
