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

class ScreenshotCell: UICollectionViewCell {
    
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
        image.layer.theme_borderColor = Color.borderCgColor
        image.image = #imageLiteral(resourceName: "placeholderCover")
        
        contentView.addSubview(image)
        contentView.addSubview(dim)
        
        setConstraints()
    }
    
    func setConstraints() {
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
            UIView.animate(withDuration: 0.1, animations: { self.dim.layer.opacity = self.isHighlighted ? DimmableView.opacity : 0 })
        }
    }
}
