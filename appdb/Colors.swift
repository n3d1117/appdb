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
    
    /////////////////
    //             //
    //  UI COLORS  //
    //             //
    /////////////////
    
    /* Blue main tint, may not be final */
    static let mainTint: ThemeColorPicker = ["#446CB3", "#6FACFA"]
    
    /* Category, author, seeAll button */
    static let darkGray: ThemeColorPicker = ["#6F7179", "#9c9c9c"]
    
    /* Background color, used for tableView and fill spaces */
    static let tableViewBackgroundColor: ThemeColorPicker = ["#EFEFF4", "#121212"]
    
    /* TableView separator color */
    static let borderColor: ThemeColorPicker = ["#C7C7CC", "#373737"]
    
    /* Error message, copyright text */
    static let copyrightText: ThemeColorPicker = ["#555555", "#7E7E7E"]
    
    /* Slightly different than background, used for tableView cells */
    static let veryVeryLightGray: ThemeColorPicker = ["#FDFDFD", "#1E1E1E"]
    
    /* Black for light theme, white for dark theme */
    static let title: ThemeColorPicker = ["#121212", "#F8F8F8"]
    
    /* White for light theme, black for dark theme */
    static let invertedTitle: ThemeColorPicker = ["#F8F8F8", "#121212"]
    
    /* Cell selection overlay color */
    static let cellSelectionColor: ThemeColorPicker = ["#D8D8D8", "#595959"]
    
    /* Matches translucent barStyle color */
    static let popoverArrowColor: ThemeColorPicker = ["#F6F6F7", "#161616"]
    
    
    /////////////////
    //             //
    //  CG COLORS  //
    //             //
    /////////////////
    
    /* CG version of copyrightText */
    static let copyrightTextCgColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#555555", "#7E7E7E")
    
    /* Icon layer borderColor */
    static let borderCgColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#C7C7CC", "#1E1E1E")
    
    /* CG version of tableViewBackgroundColor */
    static let tableViewCGBackgroundColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#EFEFF4", "#121212")
    
    /* Hardcoded Apple's UIButton selected color */
    static let buttonBorderCgColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#D0D0D4", "#272727")
}
