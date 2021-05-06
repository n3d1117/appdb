//
//  LocalIPACell.swift
//  appdb
//
//  Created by ned on 28/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography
import Alamofire

class LocalIPACell: UICollectionViewCell {

    private var filename: UILabel!
    private var size: UILabel!
    private var moreImageButton: UIImageView!
    private var dummy: UIView!
    private var semaphore = false
    private var progressView: UIProgressView!

    func updateText(_ text: String) {
        size.text = text
    }

    // Called when there's not upload request
    func configure(with ipa: LocalIPAFile) {
        filename.text = ipa.filename
        size.text = ipa.size
        progressView.isHidden = true
    }

    // Called when an upload request is in progress
    func configureForUpload(with ipa: LocalIPAFile, util: LocalIPAUploadUtil) {
        filename.text = ipa.filename
        progressView.isHidden = false
        semaphore = false

        size.text = util.lastCachedProgress
        progressView.progress = util.lastCachedFraction

        util.onProgress = { fraction, text in
            if !self.semaphore, !util.isPaused { // prevent wrong cell text update after reuse
                self.size.text = text
                self.progressView.setProgress(fraction, animated: true)
            }
        }

        util.onPause = {
            if let partial = util.lastCachedProgress.components(separatedBy: "Uploading".localized() + " ").last {
                self.size.text = "Paused".localized() + " - \(partial)"
            } else {
                self.size.text = "Paused"
            }
        }

        util.onCompletion = {
            self.filename.text = ipa.filename
            self.size.text = ipa.size
            delay(0.1) {
                self.progressView.isHidden = true
                self.progressView.progress = 0.0
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        semaphore = true
        filename.text = ""
        size.text = ""
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
        if #available(iOS 13.0, *) {
            contentView.layer.cornerRadius = 10
        } else {
            contentView.layer.cornerRadius = 6
        }
        contentView.layer.borderWidth = 1 / UIScreen.main.scale
        contentView.layer.theme_borderColor = Color.borderCgColor
        layer.backgroundColor = UIColor.clear.cgColor

        // Filename
        filename = UILabel()
        filename.theme_textColor = Color.title
        filename.font = .systemFont(ofSize: 16 ~~ 15)
        filename.numberOfLines = 1
        filename.makeDynamicFont()

        // Info
        size = UILabel()
        size.theme_textColor = Color.darkGray
        size.font = .systemFont(ofSize: 13 ~~ 12)
        size.numberOfLines = 1
        size.makeDynamicFont()

        // Progress view
        progressView = UIProgressView()
        progressView.trackTintColor = .clear
        progressView.theme_progressTintColor = Color.mainTint
        progressView.progress = 0
        progressView.isHidden = true

        // More image button
        moreImageButton = UIImageView(image: #imageLiteral(resourceName: "more"))
        moreImageButton.alpha = 0.9

        dummy = UIView()

        contentView.addSubview(filename)
        contentView.addSubview(size)
        contentView.addSubview(moreImageButton)
        contentView.addSubview(progressView)
        contentView.addSubview(dummy)

        constrain(filename, size, moreImageButton, progressView, dummy) { name, size, moreButton, progress, dummy in
            moreButton.centerY ~== moreButton.superview!.centerY
            moreButton.trailing ~== moreButton.superview!.trailing ~- Global.Size.margin.value
            moreButton.width ~== (22 ~~ 20)
            moreButton.height ~== moreButton.width

            dummy.height ~== 1
            dummy.centerY ~== dummy.superview!.centerY

            name.leading ~== name.superview!.leading ~+ Global.Size.margin.value
            name.trailing ~== moreButton.leading ~- Global.Size.margin.value
            name.bottom ~== dummy.top ~+ 2

            size.leading ~== name.leading
            size.trailing ~== name.trailing
            size.top ~== dummy.bottom ~+ 3

            progress.bottom ~== progress.superview!.bottom
            progress.leading ~== progress.superview!.leading
            progress.trailing ~== progress.superview!.trailing
        }
    }

    // Hover animation
    override var isHighlighted: Bool {
        didSet {
            if #available(iOS 13.0, *) { return }
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
