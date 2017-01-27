//
//  NSObject+Theme.swift
//  SwiftTheme
//
//  Created by Gesen on 16/1/22.
//  Copyright © 2016年 Gesen. All rights reserved.
//

import UIKit

extension NSObject {
    
    public typealias ThemePickers = [String: ThemePicker]
    
    public var themePickers: ThemePickers {
        get {
            if let themePickers = objc_getAssociatedObject(self, &themePickersKey) as? ThemePickers {
                return themePickers
            }
            let initValue = ThemePickers()
            objc_setAssociatedObject(self, &themePickersKey, initValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return initValue
        }
        set {
            objc_setAssociatedObject(self, &themePickersKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            _removeThemeNotification()
            if newValue.isEmpty == false { _setupThemeNotification() }
        }
    }
    
    func performThemePicker(selector: String, picker: ThemePicker?) {
        let sel = Selector(selector)
        let methodSignature = self.method(for: sel)
        guard responds(to: sel)     else { return }
        guard let value = picker?.value() else { return }
        
        if let statePicker = picker as? ThemeStatePicker {
            let setState = unsafeBitCast(methodSignature, to: setValueForStateIMP.self)
            statePicker.values.forEach { setState(self, sel, $1.value()! as AnyObject, UIControlState(rawValue: $0)) }
        }
            
        else if let statusBarStylePicker = picker as? ThemeStatusBarStylePicker {
            let setStatusBarStyle = unsafeBitCast(methodSignature, to: setStatusBarStyleValueIMP.self)
            setStatusBarStyle(self, sel, statusBarStylePicker.currentStyle(value as AnyObject?), statusBarStylePicker.animated)
            
        }
        
        else if picker is ThemeCGFloatPicker {
            let setCGFloat = unsafeBitCast(methodSignature, to: setCGFloatValueIMP.self)
            setCGFloat(self, sel, value as! CGFloat)
        }
        
        else if picker is ThemeCGColorPicker {
            let setCGColor = unsafeBitCast(methodSignature, to: setCGColorValueIMP.self)
            setCGColor(self, sel, value as! CGColor)
        }
        
        else { perform(sel, with: value) }
    }
    
    fileprivate typealias setCGColorValueIMP        = @convention(c) (NSObject, Selector, CGColor) -> Void
    fileprivate typealias setCGFloatValueIMP        = @convention(c) (NSObject, Selector, CGFloat) -> Void
    fileprivate typealias setValueForStateIMP       = @convention(c) (NSObject, Selector, AnyObject, UIControlState) -> Void
    fileprivate typealias setStatusBarStyleValueIMP = @convention(c) (NSObject, Selector, UIStatusBarStyle, Bool) -> Void
    
}

extension NSObject {
    
    fileprivate func _setupThemeNotification() {
        if #available(iOS 9.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(_updateTheme), name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
        } else {
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil, queue: nil, using: { [weak self] notification in self?._updateTheme() })
        }
    }
    
    fileprivate func _removeThemeNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ThemeUpdateNotification), object: nil)
    }
    
    @objc private func _updateTheme() {
        themePickers.forEach { selector, picker in
            UIView.animate(withDuration: ThemeManager.animationDuration, animations: {
                self.performThemePicker(selector: selector, picker: picker)
            }) 
        }
    }
    
}

private var themePickersKey = ""
