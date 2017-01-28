//
//  ThemeDictionaryPicker.swift
//  SwiftTheme
//
//  Created by Gesen on 2017/1/28.
//  Copyright © 2017年 Gesen. All rights reserved.
//

import Foundation

public final class ThemeDictionaryPicker: ThemePicker {
    
    public convenience init(dicts: [String: AnyObject]...) {
        self.init(v: { ThemeManager.elementForArray(dicts) })
    }
    
    public required convenience init(arrayLiteral elements: [String: AnyObject]...) {
        self.init(v: { ThemeManager.elementForArray(elements) })
    }
    
    public class func pickerWithDicts(_ dicts: [[String: AnyObject]]) -> ThemeDictionaryPicker {
        return ThemeDictionaryPicker(v: { ThemeManager.elementForArray(dicts) })
    }
    
}

extension ThemeDictionaryPicker: ExpressibleByArrayLiteral {}
