//
//  Banner.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography
import AlamofireImage
import ImageSlideshow

class Banner: UITableViewCell {

    var slideshow: ImageSlideshow!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    static let height : CGFloat = {
        let w: Double = Double(UIScreen.main.bounds.width)
        let h: Double = Double(UIScreen.main.bounds.height)
        let screenHeight: Double = max(w, h)
        
        switch screenHeight {
            case 480,568: return 128
            case 667: return 150
            case 736: return 165.6
            case 1024: return 220
            case 1366: return 250
            default: return 0
        }
        
    }()
    
    convenience init() {
        self.init(style: .default, reuseIdentifier: Featured.CellType.banner.rawValue)
        
        theme_backgroundColor = Color.tableViewBackgroundColor
        contentView.theme_backgroundColor = Color.tableViewBackgroundColor
        
        //
        // Get Promotions
        // TODO: ask fred to add banner image to API
        //
        
        /*API.getPromotions( success: { items in
            
            if items.isEmpty {
                print("no promotions to show")
            } else {
                print("found \(items.count) promotions.")
            }
            
        }, fail: { error in
            
            print(error.localizedDescription)
            
        })*/
        
        
        slideshow = ImageSlideshow()
        slideshow.setImageInputs([ AlamofireSource(urlString: "http://appd.be/n3d/delta/k.png") as! InputSource ])

        slideshow.slideshowInterval = 5.0
        slideshow.circular = true
        slideshow.zoomEnabled = false
        slideshow.pageControlPosition = .hidden
        slideshow.contentScaleMode = .scaleAspectFit
        slideshow.draggingEnabled = true
        slideshow.preload = .all
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(Banner.didTap))
        slideshow.addGestureRecognizer(tapRecognizer)
        
        contentView.addSubview(slideshow)
        
        constrain(slideshow) { slideshow in
            slideshow.edges == slideshow.superview!.edges
        }
        
    }
    
    func didTap() {
        print("did tap on \(slideshow.currentPage)") /* TODO: redirect to app page */
    }

}
