//
//  ThemeFontPicker.swift
//  SwiftTheme
//
//  Created by Gesen on 2017/1/28.
//  Copyright © 2017年 Gesen. All rights reserved.
//

import UIKit

public final class ThemeFontPicker: ThemePicker {
    
    public convenience init(fonts: UIFont...) {
        self.init(v: { ThemeManager.elementForArray(fonts) })
    }
    
    public required convenience init(arrayLiteral elements: UIFont...) {
        self.init(v: { ThemeManager.elementForArray(elements) })
    }
    
    public class func pickerWithFonts(_ fonts: [UIFont]) -> ThemeFontPicker {
        return ThemeFontPicker(v: { ThemeManager.elementForArray(fonts) })
    }
    
}

extension ThemeFontPicker: ExpressibleByArrayLiteral {}
