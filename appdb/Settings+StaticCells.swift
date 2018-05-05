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

// A simple cell for the 'Static' framework that adapts to theme changes
// and has has dynamic text font size. Used for Settings cells.

final class SimpleStaticCell: UITableViewCell, Cell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        theme_backgroundColor = Color.veryVeryLightGray
        contentView.theme_backgroundColor = Color.veryVeryLightGray
        
        let bgColorView = UIView()
        bgColorView.theme_backgroundColor = Color.cellSelectionColor
        selectedBackgroundView = bgColorView
        
        textLabel?.font = .systemFont(ofSize: (17~~16))
        textLabel?.makeDynamicFont()
        textLabel?.theme_textColor = Color.title
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
