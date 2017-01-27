//
//  PaddingLabel.swift
//  appdb
//
//  Created by ned on 27/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {
    
    let topInset = CGFloat(0.5), bottomInset = CGFloat(0.5), leftInset = CGFloat(5), rightInset = CGFloat(5)

    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
    
}
