//
//  ChevronButton.swift
//  appdb
//
//  Created by ned on 27/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

class ButtonFactory {
    
    // Returns a button with arrow on the right (such as 'See All' button)
    static func createChevronButton(text: String, color: ThemeColorPicker) -> UIButton {
        let button = UIButton(type: .system) as UIButton /* Type is system to keep nice highlighting features */
        
        button.setTitle(text, for: .normal)
        button.setImage(#imageLiteral(resourceName: "rightArrow"), for: .normal)
        button.theme_setTitleColor(color, forState: .normal)
        button.theme_tintColor = color
        if #available(iOS 8.2, *) {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10.5, weight: UIFontWeightSemibold)
        } else {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 10.5)
        }
        
        button.sizeToFit()
        
        // Hardcoded insets, do not try this at home
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
    
    // Returns a Retry button with a bolt on the left (used in No Internet view)
    static func createRetryButton(text: String, color: ThemeColorPicker) -> UIButton {
        let button = ButtonWithColoredBorder(type: .system) as UIButton /* Type is system to keep nice highlighting features */
        
        button.setTitle(text, for: .normal)
        button.theme_setImage(["bolt_dark", "bolt_light"], forState: .normal)
        button.theme_setTitleColor(color, forState: .normal)
        button.theme_tintColor = color
        if #available(iOS 8.2, *) {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)
        } else {
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        }
        
        button.layer.borderWidth = 0.8
        button.layer.cornerRadius = 5.0
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        button.isHighlighted = false /* set to false initially so the initial borderColor is set too */

        // Hardcoded insets, do not try this at home
        var imageInset = UIEdgeInsets.zero
        var titleInset = UIEdgeInsets.zero
        imageInset.left = -8; imageInset.right = 0
        titleInset.left = 2; titleInset.right = 9
        button.titleEdgeInsets = titleInset
        button.imageEdgeInsets = imageInset
        
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
