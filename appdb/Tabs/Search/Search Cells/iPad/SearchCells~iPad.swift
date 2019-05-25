//
//  SearchCells~iPad.swift
//  appdb
//
//  Created by ned on 13/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

final class PortraitScreenshotSearchCelliPad: PortraitScreenshotSearchCell {
    override var magic: CGFloat { return 1.333 }
    override var portraitSize: CGFloat { return (170 ~~ 160) }
    override var identifier: String { return "portraitscreenshotcellipad" }
}

final class PortraitScreenshotSearchCellWithStarsiPad: PortraitScreenshotSearchCellWithStars {
    override var magic: CGFloat { return 1.333 }
    override var portraitSize: CGFloat { return (170 ~~ 160) }
    override var identifier: String { return "portraitscreenshotcellstarsipad" }
}

final class TwoPortraitScreenshotsSearchCelliPad: TwoPortraitScreenshotsSearchCell {
    override var magic: CGFloat { return 1.333 }
    override var portraitSize: CGFloat { return (150 ~~ 160) }
    override var identifier: String { return "portraitscreenshotscellipad" }
}

final class TwoPortraitScreenshotsSearchCellWithStarsiPad: TwoPortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { return 1.333 }
    override var portraitSize: CGFloat { return (150 ~~ 160) }
    override var identifier: String { return "portraitscreenshotscellstarsipad" }
}

final class ThreePortraitScreenshotsSearchCelliPad: ThreePortraitScreenshotsSearchCell {
    override var magic: CGFloat { return 1.333 }
    override var identifier: String { return "threeportraitscreenshotscellipad" }
    override var compactPortraitSize: CGFloat { return (100 ~~ 110) }
}

final class ThreePortraitScreenshotsSearchCellWithStarsiPad: ThreePortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { return 1.333 }
    override var identifier: String { return "threeportraitscreenshotscellstarsipad" }
    override var compactPortraitSize: CGFloat { return (100 ~~ 110) }
}

final class LandscapeScreenshotSearchCelliPad: LandscapeScreenshotSearchCell {
    override var magic: CGFloat { return 1.333 }
    override var identifier: String { return "landscapescreenshotcellipad" }
}

final class LandscapeScreenshotSearchCellWithStarsiPad: LandscapeScreenshotSearchCellWithStars {
    override var magic: CGFloat { return 1.333 }
    override var identifier: String { return "landscapescreenshotcellstarsipad" }
}

final class MixedScreenshotsSearchCellOneiPad: MixedScreenshotsSearchCellOne {
    override var magic: CGFloat { return 1.333 }
    override var mixedPortraitSize: CGFloat { return (140 ~~ 135) }
    override var identifier: String { return "mixedscreenshotscelloneipad" }
}

final class MixedScreenshotsSearchCellOneWithStarsiPad: MixedScreenshotsSearchCellOneWithStars {
    override var magic: CGFloat { return 1.333 }
    override var mixedPortraitSize: CGFloat { return (140 ~~ 135) }
    override var identifier: String { return "mixedscreenshotscellonestarsipad" }
}

final class MixedScreenshotsSearchCellTwoiPad: MixedScreenshotsSearchCellTwo {
    override var magic: CGFloat { return 1.333 }
    override var mixedPortraitSize: CGFloat { return (140 ~~ 155) }
    override var identifier: String { return "mixedscreenshotscelltwoipad" }
}

final class MixedScreenshotsSearchCellTwoWithStarsiPad: MixedScreenshotsSearchCellTwoWithStars {
    override var magic: CGFloat { return 1.333 }
    override var mixedPortraitSize: CGFloat { return (140 ~~ 155) }
    override var identifier: String { return "mixedscreenshotscelltwostarsipad" }
}
