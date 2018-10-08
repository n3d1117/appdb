//
//  SearchCells~iPhone.swift
//  appdb
//
//  Created by ned on 13/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

final class PortraitScreenshotSearchCell_iPhone: PortraitScreenshotSearchCell {
    override var magic: CGFloat { return 1.775 }
    override var portraitSize: CGFloat { return (220~~210) }
    override var identifier: String { return "portraitscreenshotcelliphone" }
}

final class PortraitScreenshotSearchCellWithStars_iPhone: PortraitScreenshotSearchCellWithStars {
    override var magic: CGFloat { return 1.775 }
    override var portraitSize: CGFloat { return (220~~210) }
    override var identifier: String { return "portraitscreenshotcellstarsiphone" }
}

final class TwoPortraitScreenshotsSearchCell_iPhone: TwoPortraitScreenshotsSearchCell {
    override var magic: CGFloat { return 1.775 }
    override var portraitSize: CGFloat { return (220~~210) }
    override var identifier: String { return "portraitscreenshotscelliphone" }
}

final class TwoPortraitScreenshotsSearchCellWithStars_iPhone: TwoPortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { return 1.775 }
    override var portraitSize: CGFloat { return (220~~210) }
    override var identifier: String { return "portraitscreenshotscellstarsiphone" }
}

final class ThreePortraitScreenshotsSearchCell_iPhone: ThreePortraitScreenshotsSearchCell {
    override var magic: CGFloat { return 1.775 }
    override var identifier: String { return "threeportraitscreenshotscelliphone" }
    override var compactPortraitSize: CGFloat { return (130~~140) }
}

final class ThreePortraitScreenshotsSearchCellWithStars_iPhone: ThreePortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { return 1.775 }
    override var identifier: String { return "threeportraitscreenshotscellstarsiphone" }
    override var compactPortraitSize: CGFloat { return (130~~140) }
}

final class LandscapeScreenshotSearchCell_iPhone: LandscapeScreenshotSearchCell {
    override var magic: CGFloat { return 1.775 }
    override var identifier: String { return "landscapescreenshotcelliphone" }
}

final class LandscapeScreenshotSearchCellWithStars_iPhone: LandscapeScreenshotSearchCellWithStars {
    override var magic: CGFloat { return 1.775 }
    override var identifier: String { return "landscapescreenshotcellstarsiphone" }
}

final class MixedScreenshotsSearchCellOne_iPhone: MixedScreenshotsSearchCellOne {
    override var magic: CGFloat { return 1.775 }
    override var mixedPortraitSize: CGFloat { return (125~~120) }
    override var identifier: String { return "mixedscreenshotcelloneiphone" }
}

final class MixedScreenshotsSearchCellOneWithStars_iPhone: MixedScreenshotsSearchCellOneWithStars {
    override var magic: CGFloat { return 1.775 }
    override var mixedPortraitSize: CGFloat { return (125~~120) }
    override var identifier: String { return "mixedscreenshotcellonestarsiphone" }
}

final class MixedScreenshotsSearchCellTwo_iPhone: MixedScreenshotsSearchCellTwo {
    override var magic: CGFloat { return 1.775 }
    override var mixedPortraitSize: CGFloat { return (125~~140) }
    override var identifier: String { return "mixedscreenshotcelltwoiphone" }
}

final class MixedScreenshotsSearchCellTwoWithStars_iPhone: MixedScreenshotsSearchCellTwoWithStars {
    override var magic: CGFloat { return 1.775 }
    override var mixedPortraitSize: CGFloat { return (125~~140) }
    override var identifier: String { return "mixedscreenshotcelltwostarsiphone" }
}
