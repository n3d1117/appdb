//
//  Details+Download.swift
//  appdb
//
//  Created by ned on 18/03/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import UIKit
import Cartography
import RealmSwift

class DetailsDownload: DetailsCell {
    
    static var height: CGFloat = 60~~55
    
    var host: UILabel!
    var cracker: UILabel!
    var button: RoundedButton!
    
    lazy var bgColorView: UIView = {
        let view = UIView()
        view.theme_backgroundColor = Color.cellSelectionColor
        return view
    }()
    
    func configure(with link: Link) {
        host.text = link.host
        cracker.text = link.cracker.decoded
        cracker.theme_textColor = link.verified ? Color.softGreen : Color.softRed
        button.linkId = link.id
        button.isHidden = !link.di_compatible
        host.theme_textColor = link.universal ? Color.mainTint : Color.title
        
        selectionStyle = accessoryType == .none ? .none : .default
        constrain(button) { button in
            button.right == button.superview!.right - (accessoryType == .none ? Global.size.margin.value : 10)
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
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        theme_backgroundColor = Color.veryVeryLightGray
        selectedBackgroundView = bgColorView
        
        host = UILabel()
        host.font = .systemFont(ofSize: (16~~15))
        host.makeDynamicFont()
        host.numberOfLines = 1
        
        cracker = UILabel()
        cracker.font = .systemFont(ofSize: (13~~12))
        cracker.makeDynamicFont()
        cracker.numberOfLines = 1
        cracker.theme_textColor = Color.title
        
        button = RoundedButton()
        button.titleLabel?.font = .boldSystemFont(ofSize: 13)
        button.makeDynamicFont()
        button.setTitle("Install".localized().uppercased(), for: .normal)
        button.theme_tintColor = Color.softGreen
        
        contentView.addSubview(host)
        contentView.addSubview(cracker)
        contentView.addSubview(button)
        
        setConstraints()
        
    }
    
    override func setConstraints() {
        constrain(host, cracker, button) { host, cracker, button in
            
            button.centerY == button.superview!.centerY
            
            host.top == host.superview!.top + 9
            host.left == host.superview!.left + Global.size.margin.value
            host.right <= button.left - 9
            
            cracker.left == host.left
            cracker.right <= button.left - Global.size.margin.value
            cracker.bottom == cracker.superview!.bottom - 10
        }
    }
}
