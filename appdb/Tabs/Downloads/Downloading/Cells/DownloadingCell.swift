//
//  DownloadingCell.swift
//  appdb
//
//  Created by ned on 09/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography
import Alamofire
import AlamofireImage

struct DownloadingApp: Hashable {
    var filename: String = ""
    var icon: String = ""
    var util: LocalIPADownloadUtil?

    static func == (lhs: DownloadingApp, rhs: DownloadingApp) -> Bool {
        return lhs.filename == rhs.filename
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(filename)
    }
}

class DownloadingCell: UICollectionViewCell {
    
    private var iconSize: CGFloat = (50 ~~ 40)

    private var filename: UILabel!
    private var progress: UILabel!
    private var icon: UIImageView!
    private var moreImageButton: UIImageView!
    private var dummy: UIView!
    private var progressView: UIProgressView!

    private var resultString: String = ""

    func configureForDownload(with app: DownloadingApp) {
        filename.text = app.filename
        if !app.icon.isEmpty, let url = URL(string: app.icon) {
            icon.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholderIcon"), filter: Global.roundedFilter(from: iconSize),
                             imageTransition: .crossDissolve(0.2))
        } else {
            icon.image = #imageLiteral(resourceName: "blank_icon")
        }

        progressView.progress = app.util?.lastCachedFraction ?? 0

        if app.util == nil {
            self.progress.text = self.resultString
            return
        }

        progress.text = app.util?.lastCachedProgress

        app.util?.onProgress = { fraction, text in
            if !(app.util?.isPaused ?? false) {
                self.progress.text = text
                self.progressView.setProgress(fraction, animated: true)
            }
        }

        app.util?.onPause = {
            if let partial = app.util?.lastCachedProgress.components(separatedBy: "Downloading".localized() + " ").last {
                self.progress.text = "Paused".localized() + " - \(partial)"
            } else {
                self.progress.text = "Paused".localized()
            }
        }

        app.util?.onCompletion = { error in
            self.filename.text = app.filename
            self.resultString = error != nil ? error!.prettified : "File downloaded successfully".localized()
            self.progress.text = self.resultString
            delay(0.1) {
                self.progressView.progress = 0
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    func setup() {
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray

        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 6
        contentView.layer.borderWidth = 1 / UIScreen.main.scale
        contentView.layer.theme_borderColor = Color.borderCgColor
        layer.backgroundColor = UIColor.clear.cgColor

        // Filename
        filename = UILabel()
        filename.theme_textColor = Color.title
        filename.font = .systemFont(ofSize: 15 ~~ 14)
        filename.numberOfLines = 1
        filename.makeDynamicFont()

        // Progress text
        progress = UILabel()
        progress.theme_textColor = Color.darkGray
        progress.font = .systemFont(ofSize: 13 ~~ 12)
        progress.numberOfLines = 1
        progress.makeDynamicFont()

        // Icon
        icon = UIImageView()
        icon.layer.borderWidth = 1 / UIScreen.main.scale
        icon.layer.theme_borderColor = Color.borderCgColor
        icon.contentMode = .scaleToFill
        icon.layer.cornerRadius = Global.cornerRadius(from: iconSize)

        // Progress view
        progressView = UIProgressView()
        progressView.trackTintColor = .clear
        progressView.theme_progressTintColor = Color.mainTint
        progressView.progress = 0

        // More image button
        moreImageButton = UIImageView(image: #imageLiteral(resourceName: "more"))
        moreImageButton.alpha = 0.9

        dummy = UIView()

        contentView.addSubview(filename)
        contentView.addSubview(progress)
        contentView.addSubview(icon)
        contentView.addSubview(moreImageButton)
        contentView.addSubview(progressView)
        contentView.addSubview(dummy)

        constrain(filename, progress, icon, moreImageButton, progressView, dummy) { name, progress, icon, moreButton, progressView, dummy in
            icon.width ~== iconSize
            icon.height ~== icon.width
            icon.left ~== icon.superview!.left ~+ (15 ~~ 12)
            icon.centerY ~== icon.superview!.centerY

            moreButton.centerY ~== moreButton.superview!.centerY
            moreButton.right ~== moreButton.superview!.right ~- (15 ~~ 12)
            moreButton.width ~== (22 ~~ 20)
            moreButton.height ~== moreButton.width

            dummy.height ~== 1
            dummy.centerY ~== dummy.superview!.centerY

            name.left ~== icon.right ~+ (12 ~~ 10)
            name.right ~== moreButton.left ~- Global.Size.margin.value
            name.bottom ~== dummy.top ~+ 2

            progress.left ~== name.left
            progress.right ~== moreButton.left ~- (5 ~~ 0)
            progress.top ~== dummy.bottom + 3

            progressView.bottom ~== progressView.superview!.bottom
            progressView.left ~== progressView.superview!.left
            progressView.right ~== progressView.superview!.right
        }
    }

    // Hover animation
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                UIView.animate(withDuration: 0.1) {
                    self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
                }
            } else {
                UIView.animate(withDuration: 0.1) {
                    self.transform = .identity
                }
            }
        }
    }
}
