//
//  Details+DownloadCell.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import UIKit
import Cartography
import RealmSwift

class DetailsDownloadCell: DetailsCell {
    
    static var height: CGFloat { return 50 }
    
    var host: UILabel!
    var cracker: UILabel!
    var button: RoundedButton!
    
    func configure(with link: Link) {
        host.text = link.host
        cracker.text = link.cracker
        cracker.theme_textColor = link.verified ? Color.softGreen : Color.softRed
        button.linkId = link.id
        button.isHidden = !link.di_compatible
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        preservesSuperviewLayoutMargins = false
        accessoryType = .disclosureIndicator
        
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        selectedBackgroundView = bgColorView
        
        addSeparator(full: true)
        
        // UI
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray
        
        host = UILabel()
        host.font = .systemFont(ofSize: (16~~15))
        host.numberOfLines = 1
        host.theme_textColor = Color.title
        
        cracker = UILabel()
        cracker.font = .systemFont(ofSize: (13~~12))
        cracker.numberOfLines = 1
        cracker.theme_textColor = Color.title
        
        button = RoundedButton()
        button.titleLabel?.font = .boldSystemFont(ofSize: 13)
        button.setTitle("Install".localized().uppercased(), for: .normal)
        button.theme_tintColor = Color.softGreen
        button.drawPlusIcon = false
        
        contentView.addSubview(host)
        contentView.addSubview(cracker)
        contentView.addSubview(button)
        
        setConstraints()
        
    }
    
    override func setConstraints() {
        if !didSetupConstraints { didSetupConstraints = true
            constrain(host, cracker, button) { host, cracker, button in
                
                button.right == button.superview!.right - 10
                button.centerY == button.superview!.centerY
                
                host.top == host.superview!.top + 8
                host.left == host.superview!.left + Featured.size.margin.value
                host.right <= button.left - 10
                
                cracker.left == host.left
                cracker.right <= button.left - 10
                cracker.bottom == cracker.superview!.bottom - 8
            }
        }
    }
}
