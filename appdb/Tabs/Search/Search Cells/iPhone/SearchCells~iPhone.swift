//
//  SearchCells~iPhone.swift
//  appdb
//
//  Created by ned on 13/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

final class PortraitScreenshotSearchCelliPhone: PortraitScreenshotSearchCell {
    override var magic: CGFloat { return 1.775 }
    override var portraitSize: CGFloat { return (220 ~~ 210) }
    override var identifier: String { return "portraitscreenshotcelliphone" }
}

final class PortraitScreenshotSearchCellWithStarsiPhone: PortraitScreenshotSearchCellWithStars {
    override var magic: CGFloat { return 1.775 }
    override var portraitSize: CGFloat { return (220 ~~ 210) }
    override var identifier: String { return "portraitscreenshotcellstarsiphone" }
}

final class TwoPortraitScreenshotsSearchCelliPhone: TwoPortraitScreenshotsSearchCell {
    override var magic: CGFloat { return 1.775 }
    override var portraitSize: CGFloat { return (220 ~~ 210) }
    override var identifier: String { return "portraitscreenshotscelliphone" }
}

final class TwoPortraitScreenshotsSearchCellWithStarsiPhone: TwoPortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { return 1.775 }
    override var portraitSize: CGFloat { return (220 ~~ 210) }
    override var identifier: String { return "portraitscreenshotscellstarsiphone" }
}

final class ThreePortraitScreenshotsSearchCelliPhone: ThreePortraitScreenshotsSearchCell {
    override var magic: CGFloat { return 1.775 }
    override var identifier: String { return "threeportraitscreenshotscelliphone" }
    override var compactPortraitSize: CGFloat { return (130 ~~ 140) }
}

final class ThreePortraitScreenshotsSearchCellWithStarsiPhone: ThreePortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { return 1.775 }
    override var identifier: String { return "threeportraitscreenshotscellstarsiphone" }
    override var compactPortraitSize: CGFloat { return (130 ~~ 140) }
}

final class LandscapeScreenshotSearchCelliPhone: LandscapeScreenshotSearchCell {
    override var magic: CGFloat { return 1.775 }
    override var identifier: String { return "landscapescreenshotcelliphone" }
}

final class LandscapeScreenshotSearchCellWithStarsiPhone: LandscapeScreenshotSearchCellWithStars {
    override var magic: CGFloat { return 1.775 }
    override var identifier: String { return "landscapescreenshotcellstarsiphone" }
}

final class MixedScreenshotsSearchCellOneiPhone: MixedScreenshotsSearchCellOne {
    override var magic: CGFloat { return 1.775 }
    override var mixedPortraitSize: CGFloat { return (125 ~~ 130) }
    override var identifier: String { return "mixedscreenshotcelloneiphone" }
}

final class MixedScreenshotsSearchCellOneWithStarsiPhone: MixedScreenshotsSearchCellOneWithStars {
    override var magic: CGFloat { return 1.775 }
    override var mixedPortraitSize: CGFloat { return (125 ~~ 120) }
    override var identifier: String { return "mixedscreenshotcellonestarsiphone" }
}

final class MixedScreenshotsSearchCellTwoiPhone: MixedScreenshotsSearchCellTwo {
    override var magic: CGFloat { return 1.775 }
    override var mixedPortraitSize: CGFloat { return (125 ~~ 140) }
    override var identifier: String { return "mixedscreenshotcelltwoiphone" }
}

final class MixedScreenshotsSearchCellTwoWithStarsiPhone: MixedScreenshotsSearchCellTwoWithStars {
    override var magic: CGFloat { return 1.775 }
    override var mixedPortraitSize: CGFloat { return (125 ~~ 140) }
    override var identifier: String { return "mixedscreenshotcelltwostarsiphone" }
}
