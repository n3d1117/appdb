//
//  ChevronButton.swift
//  appdb
//
//  Created by ned on 27/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

struct ButtonFactory {
    
    // Returns a button with arrow on the right (such as 'See All' button)
    static func createChevronButton(text: String, color: ThemeColorPicker, size: CGFloat = 10.5, bold: Bool = true) -> UIButton {
        let button = UIButton(type: .system) as UIButton /* Type is system to keep nice highlighting features */
        
        button.setTitle(text, for: .normal)
        button.setImage(#imageLiteral(resourceName: "rightArrow"), for: .normal)
        button.theme_setTitleColor(color, forState: .normal)
        button.theme_tintColor = color
        if #available(iOS 8.2, *), bold {
            button.titleLabel?.font = UIFont.systemFont(ofSize: size, weight: UIFontWeightSemibold)
        } else {
            button.titleLabel?.font = UIFont.systemFont(ofSize: size)
        }
        button.contentHorizontalAlignment = .left
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        
        button.sizeToFit()
        
        // What the fuck is this
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -button.imageRect(forContentRect: button.bounds).size.width, 0, 0)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, button.titleRect(forContentRect: button.bounds).size.width, 0, 0)
        
        return button
    }
    
    // Returns a Retry button with a bolt on the left (used in No Internet view)
    static func createRetryButton(text: String, color: ThemeColorPicker) -> UIButton {
        let button = ButtonWithColoredBorder(type: .system) as UIButton /* Type is system to keep nice highlighting features */
        
        button.setTitle(text, for: .normal)
        button.theme_setImage(["bolt_dark", "bolt_light"], forState: .normal)
        button.theme_setTitleColor(color, forState: .normal)
        button.theme_tintColor = color
        if #available(iOS 8.2, *) {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14~~13, weight: UIFontWeightSemibold)
        } else {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14~~13)
        }
        
        button.contentHorizontalAlignment = .left
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        
        button.layer.borderWidth = 0.8
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        button.isHighlighted = false /* set to false initially so the initial borderColor is set too */

        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets.zero
        
        button.sizeToFit()
        button.tag = Int(button.bounds.width) /* pass dynamic width */ 
        
        return button
    }

}

//
// Class to match system button image/text highlighting with the border color
// Values are hardcoded to match specifically the 'Retry' button for no internet view
//
class ButtonWithColoredBorder : UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted { layer.theme_borderColor = Color.buttonBorderCgColor } /* apple's button selected color */
            else { layer.theme_borderColor = Color.copyrightTextCgColor } /* hardcoded to match LoadingTableView */
        }
    }
}
