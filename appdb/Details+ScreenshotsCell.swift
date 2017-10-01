//
//  Details+ScreenshotsCell.swift
//  appdb
//
//  Created by ned on 22/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography
import Alamofire

class DetailsScreenshotCell: UICollectionViewCell {
    
    var didSetupConstraints: Bool = false
    var image: UIImageView!
    var dim: UIView = DimmableView.get()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        image = UIImageView()
        image.layer.borderWidth = 1 / UIScreen.main.scale
        image.layer.cornerRadius = 7
        image.layer.masksToBounds = true
        image.layer.theme_borderColor = Color.borderCgColor
        image.image = #imageLiteral(resourceName: "placeholderCover")
        
        dim.layer.cornerRadius = image.layer.cornerRadius
        
        contentView.addSubview(image)
        contentView.addSubview(dim)
        
        setConstraints()
    }
    
    fileprivate func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(image, dim) { image, dim in
                
                image.edges == image.superview!.edges
                dim.edges == image.edges
                
            }
        }
    }
    
    // Hover icon
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.dim.isHidden = false
                self.dim.layer.opacity = DimmableView.opacity
            } else {
                UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: { [unowned self] in
                    self.dim.layer.opacity = 0
                    }, completion: { _ in
                        self.dim.isHidden = true
                })
            }
        }
    }
}
