//
//  SearchCells~iPhone.swift
//  appdb
//
//  Created by ned on 13/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

final class PortraitScreenshotSearchCelliPhone: PortraitScreenshotSearchCell {
    override var magic: CGFloat { 1.775 }
    override var portraitSize: CGFloat { (220 ~~ 210) }
    override var identifier: String { "portraitscreenshotcelliphone" }
}

final class PortraitScreenshotSearchCellWithStarsiPhone: PortraitScreenshotSearchCellWithStars {
    override var magic: CGFloat { 1.775 }
    override var portraitSize: CGFloat { (220 ~~ 210) }
    override var identifier: String { "portraitscreenshotcellstarsiphone" }
}

final class TwoPortraitScreenshotsSearchCelliPhone: TwoPortraitScreenshotsSearchCell {
    override var magic: CGFloat { 1.775 }
    override var portraitSize: CGFloat { (220 ~~ 210) }
    override var identifier: String { "portraitscreenshotscelliphone" }
}

final class TwoPortraitScreenshotsSearchCellWithStarsiPhone: TwoPortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { 1.775 }
    override var portraitSize: CGFloat { (220 ~~ 210) }
    override var identifier: String { "portraitscreenshotscellstarsiphone" }
}

final class ThreePortraitScreenshotsSearchCelliPhone: ThreePortraitScreenshotsSearchCell {
    override var magic: CGFloat { 1.775 }
    override var identifier: String { "threeportraitscreenshotscelliphone" }
    override var compactPortraitSize: CGFloat { (130 ~~ 140) }
}

final class ThreePortraitScreenshotsSearchCellWithStarsiPhone: ThreePortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { 1.775 }
    override var identifier: String { "threeportraitscreenshotscellstarsiphone" }
    override var compactPortraitSize: CGFloat { (130 ~~ 140) }
}

final class LandscapeScreenshotSearchCelliPhone: LandscapeScreenshotSearchCell {
    override var magic: CGFloat { 1.775 }
    override var identifier: String { "landscapescreenshotcelliphone" }
}

final class LandscapeScreenshotSearchCellWithStarsiPhone: LandscapeScreenshotSearchCellWithStars {
    override var magic: CGFloat { 1.775 }
    override var identifier: String { "landscapescreenshotcellstarsiphone" }
}

final class MixedScreenshotsSearchCellOneiPhone: MixedScreenshotsSearchCellOne {
    override var magic: CGFloat { 1.775 }
    override var mixedPortraitSize: CGFloat { (125 ~~ 130) }
    override var identifier: String { "mixedscreenshotcelloneiphone" }
}

final class MixedScreenshotsSearchCellOneWithStarsiPhone: MixedScreenshotsSearchCellOneWithStars {
    override var magic: CGFloat { 1.775 }
    override var mixedPortraitSize: CGFloat { (125 ~~ 120) }
    override var identifier: String { "mixedscreenshotcellonestarsiphone" }
}

final class MixedScreenshotsSearchCellTwoiPhone: MixedScreenshotsSearchCellTwo {
    override var magic: CGFloat { 1.775 }
    override var mixedPortraitSize: CGFloat { (125 ~~ 140) }
    override var identifier: String { "mixedscreenshotcelltwoiphone" }
}

final class MixedScreenshotsSearchCellTwoWithStarsiPhone: MixedScreenshotsSearchCellTwoWithStars {
    override var magic: CGFloat { 1.775 }
    override var mixedPortraitSize: CGFloat { (125 ~~ 140) }
    override var identifier: String { "mixedscreenshotcelltwostarsiphone" }
}
