//
//  ChevronButton.swift
//  appdb
//
//  Created by ned on 27/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

enum ButtonFactory {

    // Returns a button with arrow on the right (such as 'See All' button)
    static func createChevronButton(text: String, color: ThemeColorPicker, size: CGFloat = 11.5, bold: Bool = true) -> UIButton {
        let button = UIButton(type: .system) /* Type is system to keep nice highlighting features */

        button.setTitle(text, for: .normal)
        let image = #imageLiteral(resourceName: "rightArrow").withRenderingMode(.alwaysTemplate).imageFlippedForRightToLeftLayoutDirection()
        button.setImage(image, for: .normal)
        button.theme_setTitleColor(color, forState: .normal)
        button.theme_tintColor = color
        if bold {
            button.titleLabel?.font = .systemFont(ofSize: size, weight: .semibold)
        } else {
            button.titleLabel?.font = .systemFont(ofSize: size)
        }
        button.makeDynamicFont()
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.lineBreakMode = .byTruncatingTail

        button.imageView!.contentMode = .center
        button.sizeToFit()

        if Global.isRtl {
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -button.imageRect(forContentRect: button.bounds).size.width)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: button.titleRect(forContentRect: button.bounds).size.width)
        } else {
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -button.imageRect(forContentRect: button.bounds).size.width, bottom: 0, right: 0)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: button.titleRect(forContentRect: button.bounds).size.width, bottom: 0, right: 0)
        }

        return button
    }

    // Returns a Retry button with a bolt on the left (used in No Internet view)
    static func createRetryButton(text: String, color: ThemeColorPicker = Color.copyrightText) -> UIButton {
        let button = BouncyButtonWithColoredBorder()

        button.setTitle(text, for: .normal)
        button.theme_setImage(["bolt_dark", "bolt_light", "bolt_light"], forState: .normal)
        button.setImage(button.imageView!.image!.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.theme_tintColor = color
        button.theme_setTitleColor(color, forState: .normal)
        button.theme_setTitleColor(Color.buttonBorderColor, forState: .highlighted)
        button.theme_tintColor = color
        button.titleLabel?.font = .systemFont(ofSize: (14 ~~ 13), weight: .semibold)

        button.makeDynamicFont()
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.lineBreakMode = .byTruncatingTail

        button.layer.borderWidth = 0.8
        button.layer.cornerRadius = 5
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
class BouncyButtonWithColoredBorder: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                layer.theme_borderColor = Color.buttonBorderCgColor /* apple's button selected color */
                theme_tintColor = Color.buttonBorderColor
                // Bounce animation
                UIView.animate(withDuration: 0.1) {
                    self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
                }
            } else {
                layer.theme_borderColor = Color.copyrightTextCgColor /* hardcoded to match LoadingTableView */
                theme_tintColor = Color.copyrightText
                // Reset bounce animation
                UIView.animate(withDuration: 0.1) {
                    self.transform = .identity
                }
            }
        }
    }
}
