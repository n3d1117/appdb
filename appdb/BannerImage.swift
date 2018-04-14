//
//  BannerImage.swift
//  appdb
//
//  Created by ned on 13/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//


import UIKit
import Cartography

class BannerImage: UICollectionViewCell {

    var image: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        image = UIImageView()
        image.contentMode = .scaleAspectFit
        
        contentView.addSubview(image)

        constrain(image) { image in
            image.edges == image.superview!.edges
        }
    }
}
