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

final class TwoPortraitScreenshotsSearchCell_iPhone: TwoPortraitScreenshotsSearchCell {
    override var magic: CGFloat { return 1.775 }
    override var portraitSize: CGFloat { return (220~~210) }
    override var identifier: String { return "portraitscreenshotscelliphone" }
}

final class ThreePortraitScreenshotsSearchCell_iPhone: ThreePortraitScreenshotsSearchCell {
    override var magic: CGFloat { return 1.775 }
    override var identifier: String { return "threeportraitscreenshotscelliphone" }
    override var compactPortraitSize: CGFloat { return (150~~140) }
}

final class LandscapeScreenshotSearchCell_iPhone: LandscapeScreenshotSearchCell {
    override var magic: CGFloat { return 1.775 }
    override var identifier: String { return "landscapescreenshotcelliphone" }
}

final class MixedScreenshotsSearchCellOne_iPhone: MixedScreenshotsSearchCellOne {
    override var magic: CGFloat { return 1.775 }
    override var mixedPortraitSize: CGFloat { return (125~~140) }
    override var identifier: String { return "mixedscreenshotcelloneiphone" }
}

final class MixedScreenshotsSearchCellTwo_iPhone: MixedScreenshotsSearchCellTwo {
    override var magic: CGFloat { return 1.775 }
    override var mixedPortraitSize: CGFloat { return (125~~140) }
    override var identifier: String { return "mixedscreenshotcelltwoiphone" }
}
