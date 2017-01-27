//
//  Colors.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import UIKit

/* First is light theme, second is Dark theme hex. */

enum Color {
    static let mainTint: ThemeColorPicker = ["#446CB3", "#6FACFA"] /* Blue main tint */
    static let darkGray: ThemeColorPicker = ["#6F7179", "#9c9c9c"]
    static let tableViewBackgroundColor: ThemeColorPicker = ["#EFEFF4", "#121212"]
    static let borderColor: ThemeColorPicker = ["#C7C7CC", "#373737"]
    static let copyrightText: ThemeColorPicker = ["#555555", "#7E7E7E"]
    static let veryVeryLightGray: ThemeColorPicker = ["#FDFDFD", "#1E1E1E"]
    static let title: ThemeColorPicker = ["#121212", "#F8F8F8"]
    static let invertedTitle: ThemeColorPicker = ["#F8F8F8", "#121212"]
    static let cellSelectionColor: ThemeColorPicker = ["#D8D8D8", "#595959"]
    
    /* CG Colors */
    static let borderCgColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#C7C7CC", "#1E1E1E")
    static let tableViewCGBackgroundColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#EFEFF4", "#121212")
}
