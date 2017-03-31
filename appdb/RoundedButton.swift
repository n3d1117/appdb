//
//  RoundedButton.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit

public class RoundedButton: UIButton {
    
    // MARK: Initializers
    var drawPlusIcon = false
    var linkId: String = ""
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        setTitleColor(tintColor, for: .normal)
        setTitleColor(.white, for: .highlighted)
        setTitleColor(.lightGray, for: .disabled)
        
        layer.cornerRadius = 3.5
        layer.borderWidth = 1
        contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10)
        
        refreshBorderColor()
    }
    
    private func refreshBorderColor() {
        layer.borderColor = isEnabled ? tintColor?.cgColor : UIColor.lightGray.cgColor
    }
    
    // MARK: Override
    
    public override var tintColor: UIColor? {
        set(newTintColor) {
            super.tintColor = newTintColor
            setTitleColor(newTintColor, for: .normal)
            refreshBorderColor()
        }
        get { return super.tintColor }
    }
    
    override public func draw(_ rect: CGRect) {
        
        if drawPlusIcon {
            let contextRef = UIGraphicsGetCurrentContext()
            contextRef!.setFillColor(self.tintColor!.cgColor);
            
            // Fill the vertical bar with the color.
            let verticalBar = CGRect(x: 5, y: 3, width: 1, height: 5)
            contextRef!.fill(verticalBar);
            
            // Fill the horizontal bar with the color.
            let horizontalBar = CGRect(x: 3, y: 5, width: 5, height: 1)
            contextRef!.fill(horizontalBar)
        }
    }
    
    public override var isEnabled: Bool {
        didSet {
            refreshBorderColor()
        }
    }
    
    public override var isHighlighted: Bool {
        set(newHighlighted) {
            if isHighlighted != newHighlighted {
                super.isHighlighted = newHighlighted
                
                UIView.animate(withDuration: 0.25) {
                    self.layer.backgroundColor = self.isHighlighted ? self.tintColor?.cgColor : UIColor.clear.cgColor
                }
                
                setNeedsDisplay()
            }
        }
        get { return super.isHighlighted }
    }
}
