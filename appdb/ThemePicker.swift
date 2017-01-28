//
//  ThemePicker.swift
//  SwiftTheme
//
//  Created by Gesen on 16/1/25.
//  Copyright © 2016年 Gesen. All rights reserved.
//

import Foundation

public class ThemePicker: NSObject, NSCopying {
    
    public typealias ValueType = () -> Any?
    
    var value: ValueType
    
    required public init(v: @escaping ValueType) {
        value = v
    }
    
    public func copy(with zone: NSZone?) -> Any {
        return type(of: self).init(v: value)
    }
    
}
