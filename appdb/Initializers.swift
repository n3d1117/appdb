//
//  Initializers.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit
import Log
import AlamofireImage

//Logging Framework
let Log = Logger()

//Utils
let IS_IPAD = UIDevice.current.userInterfaceIdiom == .pad

struct Filters {

    static let featured = AspectScaledToFillSizeWithRoundedCornersFilter(
        size: CGSize(width: Featured.size.itemWidth.value, height: Featured.size.itemWidth.value),
        radius: cornerRadius(fromWidth: Featured.size.itemWidth.value)
    )

    static let categories = AspectScaledToFillSizeWithRoundedCornersFilter(
        size: CGSize(width: 30, height: 30),
        radius: cornerRadius(fromWidth: 30)
    )

}

