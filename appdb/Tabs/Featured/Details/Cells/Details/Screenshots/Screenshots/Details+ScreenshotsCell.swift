//
//  Details+ScreenshotsCell.swift
//  appdb
//
//  Created by ned on 22/02/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import Alamofire

class DetailsScreenshotCell: UICollectionViewCell {
    
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
        image.layer.theme_borderColor = Color.borderCgColor
        let filter = Global.screenshotRoundedFilter(size: contentView.frame.size, radius: 7)
        image.image = filter.filter(#imageLiteral(resourceName: "placeholderCover"))

        dim.layer.cornerRadius = image.layer.cornerRadius

        contentView.addSubview(image)
        contentView.addSubview(dim)

        setConstraints()
    }

    private func setConstraints() {
        constrain(image, dim) { image, dim in
            image.edges ~== image.superview!.edges
            dim.edges ~== image.edges
        }
    }

    // Hover icon    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.1) {
                    self.image.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                    self.dim.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                    self.dim.isHidden = false
                    self.dim.layer.opacity = DimmableView.opacity
                }
            } else {
                UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: { [unowned self] in
                    self.image.transform = .identity
                    self.dim.transform = .identity
                    self.dim.layer.opacity = 0
                    }, completion: { _ in
                        self.dim.isHidden = true
                })
            }
        }
    }
}
