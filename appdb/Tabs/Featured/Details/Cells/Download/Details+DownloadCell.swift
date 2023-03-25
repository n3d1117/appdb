//
//  Details+Download.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography

class DetailsDownload: DetailsCell {

    static var height: CGFloat = 135 ~~ 130

    var host: UILabel!
    var cracker: UILabel!
    var uploader: UILabel!
    var compatibility: UILabel!
    var button: RoundedButton!

    lazy var bgColorView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = Color.cellSelectionColor
        return view
    }()

    func configure(with link: Link, installEnabled: Bool) {
        host.text = link.host
        cracker.text = "Cracked by %@".localizedFormat(link.cracker.decoded)
        cracker.theme_textColor = link.verified ? Color.softGreen : Color.softRed
        uploader.text = "Uploaded by %@".localizedFormat(link.uploader.decoded)
        uploader.theme_textColor = link.verified ? Color.softGreen : Color.softRed
        button.linkId = link.id
        button.isHidden = !link.diCompatible
        button.isEnabled = installEnabled
        host.theme_textColor = link.universal ? Color.mainTint : Color.title

        selectionStyle = accessoryType == .none ? .none : .default
        
        compatibility.text = link.compatibility
        compatibility.theme_textColor = link.isCompatible ? Color.softGreen : Color.softRed
        
        if !link.reportReason.isEmpty {
            compatibility.theme_textColor = Color.softRed
            compatibility.text = "We’ve got reports reg. this link: \"%@\"".localizedFormat(link.reportReason)
        }
        
        constrain(uploader, compatibility, button) { uploader, compatibility, button in
            
            compatibility.leading ~== uploader.leading
            compatibility.width ~<= compatibility.superview!.width * 0.9
            compatibility.top ~== uploader.bottom + 10
            
            button.trailing ~== button.superview!.trailing ~- (accessoryType == .none ? Global.Size.margin.value : 10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        preservesSuperviewLayoutMargins = false

        addSeparator(full: true)

        // UI
        setBackgroundColor(Color.veryVeryLightGray)
        theme_backgroundColor = Color.veryVeryLightGray
        selectedBackgroundView = bgColorView

        host = UILabel()
        host.font = .systemFont(ofSize: (16 ~~ 15))
        host.makeDynamicFont()
        host.numberOfLines = 1

        cracker = UILabel()
        cracker.font = .systemFont(ofSize: (12.5 ~~ 11.5))
        cracker.makeDynamicFont()
        cracker.numberOfLines = 1

        uploader = UILabel()
        uploader.font = .systemFont(ofSize: (12.5 ~~ 11.5))
        uploader.makeDynamicFont()
        uploader.numberOfLines = 1
        
        compatibility = UILabel()
        compatibility.font = .systemFont(ofSize: (12.5 ~~ 11.5))
        compatibility.makeDynamicFont()
        compatibility.numberOfLines = 2
        
        button = RoundedButton()
        button.titleLabel?.font = .boldSystemFont(ofSize: 13)
        button.makeDynamicFont()
        button.setTitle("Install".localized().uppercased(), for: .normal)
        button.theme_tintColor = Color.softGreen

        contentView.addSubview(host)
        contentView.addSubview(cracker)
        contentView.addSubview(uploader)
        contentView.addSubview(compatibility)
        contentView.addSubview(button)

        setConstraints()
    }

    override func setConstraints() {
        constrain(host, cracker, uploader, button) { host, cracker, uploader, button in
            button.centerY ~== button.superview!.centerY

            cracker.leading ~== host.leading
            cracker.trailing ~<= button.leading ~- Global.Size.margin.value
            cracker.centerY ~== button.centerY + 3
            cracker.width ~<= cracker.superview!.width * 0.65


            host.bottom ~== cracker.top ~- 25
            host.leading ~== host.superview!.leading ~+ Global.Size.margin.value
            host.width ~<= host.superview!.width * 0.9

            uploader.leading ~== cracker.leading
            uploader.trailing ~== cracker.trailing
            uploader.top ~== cracker.bottom + 1
            uploader.width ~<= uploader.superview!.width * 0.65
        }
    }
}

class DetailsDownloadUnified: DetailsCell {
    static var height: CGFloat = 125 ~~ 120

    var host: UILabel!
    var cracker: UILabel!
    var compatibility: UILabel!
    var button: RoundedButton!

    lazy var bgColorView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = Color.cellSelectionColor
        return view
    }()

    func configure(with link: Link, installEnabled: Bool) {
        host.text = link.host
        cracker.text = "Cracked and uploaded by %@".localizedFormat(link.cracker.decoded)
        cracker.theme_textColor = link.verified ? Color.softGreen : Color.softRed
        button.linkId = link.id
        button.isHidden = !link.diCompatible
        button.isEnabled = installEnabled
        button.setTitle(button.isHidden ? "" : "Install".localized().uppercased(), for: .normal)
        host.theme_textColor = link.universal ? Color.mainTint : Color.title

        selectionStyle = accessoryType == .none ? .none : .default
        
        compatibility.text = link.compatibility
        compatibility.theme_textColor = link.isCompatible ? Color.softGreen : Color.softRed
        
        if !link.reportReason.isEmpty {
            compatibility.theme_textColor = Color.softRed
            compatibility.text = "We’ve got reports reg. this link: \"%@\"".localizedFormat(link.reportReason)
        }
        
        constrain(cracker, compatibility, button) { cracker, compatibility, button in
            
            compatibility.leading ~== cracker.leading
            compatibility.width ~<= compatibility.superview!.width * 0.9
            compatibility.top ~== cracker.bottom + 20
            
            button.trailing ~== button.superview!.trailing ~- (accessoryType == .none ? Global.Size.margin.value : 10)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        preservesSuperviewLayoutMargins = false

        addSeparator(full: true)

        // UI
        setBackgroundColor(Color.veryVeryLightGray)
        theme_backgroundColor = Color.veryVeryLightGray
        selectedBackgroundView = bgColorView

        host = UILabel()
        host.font = .systemFont(ofSize: (16 ~~ 15))
        host.makeDynamicFont()
        host.numberOfLines = 1

        cracker = UILabel()
        cracker.font = .systemFont(ofSize: (13 ~~ 12))
        cracker.makeDynamicFont()
        cracker.numberOfLines = 1
        cracker.theme_textColor = Color.title
        
        compatibility = UILabel()
        compatibility.font = .systemFont(ofSize: (12.5 ~~ 11.5))
        compatibility.makeDynamicFont()
        compatibility.numberOfLines = 2

        button = RoundedButton()
        button.titleLabel?.font = .boldSystemFont(ofSize: 13)
        button.makeDynamicFont()
        button.theme_tintColor = Color.softGreen

        contentView.addSubview(host)
        contentView.addSubview(cracker)
        contentView.addSubview(compatibility)
        contentView.addSubview(button)

        setConstraints()
    }

    override func setConstraints() {
        constrain(host, cracker, button) { host, cracker, button in
            button.centerY ~== button.superview!.centerY

            host.top ~== button.top ~- 25
            host.leading ~== host.superview!.leading ~+ Global.Size.margin.value
            host.width ~<= host.superview!.width * 0.9

            cracker.leading ~== host.leading
            cracker.trailing ~== host.trailing
            cracker.top ~== host.bottom ~+ 3
            cracker.width ~<= cracker.superview!.width * 0.65
        }
    }
}
