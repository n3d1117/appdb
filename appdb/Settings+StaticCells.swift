//
//  Settings+StaticCells.swift
//  appdb
//
//  Created by ned on 16/03/2018.
//  Copyright © 2018 ned. All rights reserved.
//


import UIKit
import Static
import SwiftTheme
import Cartography

// A simple cell for the 'Static' framework that adapts to theme changes
// and has has dynamic text font size. Used for Settings cells.

final class SimpleStaticCell: UITableViewCell, Cell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        
        textLabel?.font = .systemFont(ofSize: (17~~16))
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.title
    }
    
    func configure(row: Row) {
        textLabel?.text = row.text
        detailTextLabel?.text = row.detailText
        imageView?.image = row.image
        accessoryType = row.accessory.type
        accessoryView = row.accessory.view
        if let disableSelection = row.context?["disableSelection"] as? Bool, disableSelection {
            selectionStyle = .none
        } else {
            let bgColorView = UIView()
            bgColorView.theme_backgroundColor = Color.cellSelectionColor
            selectedBackgroundView = bgColorView
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Simple cell that shows a button in center

final class SimpleStaticButtonCell: UITableViewCell, Cell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        textLabel?.font = .systemFont(ofSize: (17~~16))
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.invertedTitle
        textLabel?.textAlignment = .center
    }
    
    func configure(row: Row) {
        textLabel?.text = row.text
        theme_backgroundColor = row.context?["bgColor"] as? ThemeColorPicker
        contentView.theme_backgroundColor = row.context?["bgColor"] as? ThemeColorPicker
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// PRO status cell

final class SimpleStaticPROStatusCell: UITableViewCell, Cell {
    
    private lazy var activeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: (15~~14))
        label.makeDynamicFont()
        label.textAlignment = .right
        return label
    }()
    
    private lazy var expirationLabel: UILabel = {
        let label = UILabel()
        label.theme_textColor = Color.darkGray
        label.font = .systemFont(ofSize: (13~~12))
        label.makeDynamicFont()
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        textLabel?.font = .systemFont(ofSize: (17~~16))
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.title
        
        contentView.addSubview(activeLabel)
    }
    
    func configure(row: Row) {
        
        textLabel?.text = row.text
        
        guard let expirationDate = (row.context?["expire"] as? String)?.rfc2822decodedShort else { return }
        guard let pro = row.context?["active"] as? Bool else { return }

        if pro {
            activeLabel.theme_textColor = Color.softGreen
            contentView.addSubview(expirationLabel)
            constrain(activeLabel, expirationLabel) { active, expiration in
                active.centerY == active.superview!.centerY - (8~~6)
                active.trailing == active.superview!.trailingMargin
                
                expiration.top == active.bottom
                expiration.trailing == active.trailing
            }
            expirationLabel.text = "Expires on \(expirationDate)"
        } else {
            activeLabel.theme_textColor = Color.softRed
            constrain(activeLabel) { active in
                active.centerY == active.superview!.centerY
                active.trailing == active.superview!.trailingMargin
            }
        }
    
        activeLabel.text = pro ? "Active" : "Inactive"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
