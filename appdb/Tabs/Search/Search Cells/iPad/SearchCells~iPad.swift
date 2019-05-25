//
//  SearchCells~iPad.swift
//  appdb
//
//  Created by ned on 13/10/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit

final class PortraitScreenshotSearchCell_iPad: PortraitScreenshotSearchCell {
    override var magic: CGFloat { return 1.333 }
    override var portraitSize: CGFloat { return (170~~160) }
    override var identifier: String { return "portraitscreenshotcellipad" }
}

final class PortraitScreenshotSearchCellWithStars_iPad: PortraitScreenshotSearchCellWithStars {
    override var magic: CGFloat { return 1.333 }
    override var portraitSize: CGFloat { return (170~~160) }
    override var identifier: String { return "portraitscreenshotcellstarsipad" }
}

final class TwoPortraitScreenshotsSearchCell_iPad: TwoPortraitScreenshotsSearchCell {
    override var magic: CGFloat { return 1.333 }
    override var portraitSize: CGFloat { return (150~~160) }
    override var identifier: String { return "portraitscreenshotscellipad" }
}

final class TwoPortraitScreenshotsSearchCellWithStars_iPad: TwoPortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { return 1.333 }
    override var portraitSize: CGFloat { return (150~~160) }
    override var identifier: String { return "portraitscreenshotscellstarsipad" }
}

final class ThreePortraitScreenshotsSearchCell_iPad: ThreePortraitScreenshotsSearchCell {
    override var magic: CGFloat { return 1.333 }
    override var identifier: String { return "threeportraitscreenshotscellipad" }
    override var compactPortraitSize: CGFloat { return (100~~110) }
}

final class ThreePortraitScreenshotsSearchCellWithStars_iPad: ThreePortraitScreenshotsSearchCellWithStars {
    override var magic: CGFloat { return 1.333 }
    override var identifier: String { return "threeportraitscreenshotscellstarsipad" }
    override var compactPortraitSize: CGFloat { return (100~~110) }
}

final class LandscapeScreenshotSearchCell_iPad: LandscapeScreenshotSearchCell {
    override var magic: CGFloat { return 1.333 }
    override var identifier: String { return "landscapescreenshotcellipad" }
}

final class LandscapeScreenshotSearchCellWithStars_iPad: LandscapeScreenshotSearchCellWithStars {
    override var magic: CGFloat { return 1.333 }
    override var identifier: String { return "landscapescreenshotcellstarsipad" }
}

final class MixedScreenshotsSearchCellOne_iPad: MixedScreenshotsSearchCellOne {
    override var magic: CGFloat { return 1.333 }
    override var mixedPortraitSize: CGFloat { return (140~~135) }
    override var identifier: String { return "mixedscreenshotscelloneipad" }
}

final class MixedScreenshotsSearchCellOneWithStars_iPad: MixedScreenshotsSearchCellOneWithStars {
    override var magic: CGFloat { return 1.333 }
    override var mixedPortraitSize: CGFloat { return (140~~135) }
    override var identifier: String { return "mixedscreenshotscellonestarsipad" }
}

final class MixedScreenshotsSearchCellTwo_iPad: MixedScreenshotsSearchCellTwo {
    override var magic: CGFloat { return 1.333 }
    override var mixedPortraitSize: CGFloat { return (140~~155) }
    override var identifier: String { return "mixedscreenshotscelltwoipad" }
}

final class MixedScreenshotsSearchCellTwoWithStars_iPad: MixedScreenshotsSearchCellTwoWithStars {
    override var magic: CGFloat { return 1.333 }
    override var mixedPortraitSize: CGFloat { return (140~~155) }
    override var identifier: String { return "mixedscreenshotscelltwostarsipad" }
}
