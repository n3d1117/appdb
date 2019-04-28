//
//  RoundedButton.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

public class RoundedButton: UIButton {
    
    // Content id
    var linkId: String = ""
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    private func setup() {
        setTitleColor(tintColor, for: .normal)
        setTitleColor(.white, for: .highlighted)
        setTitleColor(.lightGray, for: .disabled)
        
        layer.cornerRadius = 3.5
        layer.borderWidth = 1
        contentEdgeInsets = UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)
        
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
    
    public override var isEnabled: Bool {
        didSet {
            refreshBorderColor()
        }
    }
    
    public override var isHighlighted: Bool {
        set(newHighlighted) {
            if isHighlighted != newHighlighted {
                super.isHighlighted = newHighlighted
                
                UIView.animate(withDuration: 0.2) {
                    self.layer.backgroundColor = self.isHighlighted ? self.tintColor?.cgColor : UIColor.clear.cgColor
                }
                
                setNeedsDisplay()
            }
        }
        get { return super.isHighlighted }
    }
}
