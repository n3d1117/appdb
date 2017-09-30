//
//  Details+FullScreenshotsCell.swift
//  appdb
//
//  Created by ned on 26/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography
import Alamofire

class DetailsFullScreenshotCell: UICollectionViewCell {
    
    var didSetupConstraints: Bool = false
    var image: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        image = UIImageView()
        image.layer.borderWidth = 1 / UIScreen.main.scale
        image.layer.theme_borderColor = Color.borderCgColor
        image.image = #imageLiteral(resourceName: "placeholderCover")
        image.contentMode = .scaleAspectFill
        
        contentView.addSubview(image)
        
        setConstraints()
    }
    
    fileprivate func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(image) { image in
                image.edges == image.superview!.edges
            }
        }
    }
}
