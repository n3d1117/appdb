//
//  ChevronButton.swift
//  appdb
//
//  Created by ned on 27/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

class ChevronButton {
    
    static func create(text: String, color: ThemeColorPicker) -> UIButton {
        let button = UIButton(type: .system) as UIButton
        
        button.setTitle(text, for: .normal)
        button.setImage(#imageLiteral(resourceName: "rightArrow"), for: .normal)
        button.theme_setTitleColor(color, forState: .normal)
        if #available(iOS 8.2, *) {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10.5, weight: UIFontWeightSemibold)
        } else {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10.5)
        }
        button.theme_tintColor = color
        
        button.sizeToFit()
        
        let imageRect = button.imageRect(forContentRect: button.bounds)
        let titleRect = button.titleRect(forContentRect: button.bounds)
        
        var imageInset = UIEdgeInsets.zero
        var titleInset = UIEdgeInsets.zero
        
        titleInset.left = -imageRect.size.width - 9
        imageInset.left = titleRect.size.width
        
        button.titleEdgeInsets = titleInset
        button.imageEdgeInsets = imageInset
        
        return button
    }

}
