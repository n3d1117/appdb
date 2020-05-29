//
//  SearchCells~iPad.swift
//  appdb
//
//  Created by ned on 13/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

final class PortraitScreenshotSearchCelliPad: PortraitScreenshotSearchCell {
    override var magic: CGFloat { 1.333 }
    override var portraitSize: CGFloat { (170 ~~ 160) }
    override var identifier: String { "portraitscreenshotcellipad" }
}

final class PortraitScreenshotSearchCellWithStarsiPad: PortraitScreenshotSearchCellWithStars {
    override var magic: CGFloat { 1.333 }
    override var portraitSize: CGFloat { (170 ~~ 160) }
    override var identifier: String { "portraitscreenshotcellstarsipad" }
}

final class TwoPortraitScreenshotsSearchCelliPad: TwoPortraitScreenshotsSearchCell {
    override var magic: CGFloat { 1.333 }
    override var portraitSize: CGFloat { (150 ~~ 160) }
    override var identifier: String { "portraitscreenshotscellipad" }
}

final class TwoPortraitScreenshotsSearchCellWithStarsiPad: TwoPortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { 1.333 }
    override var portraitSize: CGFloat { (150 ~~ 160) }
    override var identifier: String { "portraitscreenshotscellstarsipad" }
}

final class ThreePortraitScreenshotsSearchCelliPad: ThreePortraitScreenshotsSearchCell {
    override var magic: CGFloat { 1.333 }
    override var identifier: String { "threeportraitscreenshotscellipad" }
    override var compactPortraitSize: CGFloat { (100 ~~ 110) }
}

final class ThreePortraitScreenshotsSearchCellWithStarsiPad: ThreePortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { 1.333 }
    override var identifier: String { "threeportraitscreenshotscellstarsipad" }
    override var compactPortraitSize: CGFloat { (100 ~~ 110) }
}

final class LandscapeScreenshotSearchCelliPad: LandscapeScreenshotSearchCell {
    override var magic: CGFloat { 1.333 }
    override var identifier: String { "landscapescreenshotcellipad" }
}

final class LandscapeScreenshotSearchCellWithStarsiPad: LandscapeScreenshotSearchCellWithStars {
    override var magic: CGFloat { 1.333 }
    override var identifier: String { "landscapescreenshotcellstarsipad" }
}

final class MixedScreenshotsSearchCellOneiPad: MixedScreenshotsSearchCellOne {
    override var magic: CGFloat { 1.333 }
    override var mixedPortraitSize: CGFloat { (140 ~~ 135) }
    override var identifier: String { "mixedscreenshotscelloneipad" }
}

final class MixedScreenshotsSearchCellOneWithStarsiPad: MixedScreenshotsSearchCellOneWithStars {
    override var magic: CGFloat { 1.333 }
    override var mixedPortraitSize: CGFloat { (140 ~~ 135) }
    override var identifier: String { "mixedscreenshotscellonestarsipad" }
}

final class MixedScreenshotsSearchCellTwoiPad: MixedScreenshotsSearchCellTwo {
    override var magic: CGFloat { 1.333 }
    override var mixedPortraitSize: CGFloat { (140 ~~ 155) }
    override var identifier: String { "mixedscreenshotscelltwoipad" }
}

final class MixedScreenshotsSearchCellTwoWithStarsiPad: MixedScreenshotsSearchCellTwoWithStars {
    override var magic: CGFloat { 1.333 }
    override var mixedPortraitSize: CGFloat { (140 ~~ 155) }
    override var identifier: String { "mixedscreenshotscelltwostarsipad" }
}
