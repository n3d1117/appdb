//
//  Colors.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//


import UIKit
import SwiftTheme

/* First is light theme, second is Dark theme hex. */

struct Color {

    /////////////////
    //  UI COLORS  //
    /////////////////
    
    /* Blue main tint, may not be final */
    static let mainTint: ThemeColorPicker = ["#446CB3", "#6FACFA"]
    
    /* Darker main tint for pressed state 'Authorize' cell */
    static let darkMainTint: ThemeColorPicker = ["#486A92", "#507DB8"]
    
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
    static let cellSelectionColor: ThemeColorPicker = ["#D8D8D8", "#383838"]
    
    /* Matches translucent barStyle color */
    static let popoverArrowColor: ThemeColorPicker = ["#F6F6F7", "#161616"]
    
    /* Details+Information parameter color */
    static let informationParameter: ThemeColorPicker = ["#9A9898", "#C5C3C5"]
    
    /* Green for INSTALL button and verified crackers */
    static let softGreen: ThemeColorPicker = ["#00B600", "#00B600"]
    
    /* Red for non verified crackers button and 'Deauthorize' cell */
    static let softRed: ThemeColorPicker = ["#D32F2F", "#D32F2F"]
    
    /* Dark red for pressed 'Deauthorize' cell state */
    static let darkRed: ThemeColorPicker = ["#A32F2F", "#A32F2F"]
    
    /* Gray for timestamp in device status cell */
    static let timestampGray: ThemeColorPicker = ["#AAAAAA", "#AAAAAA"]
    
    /* Background for bulletins */
    static let easyBulletinBackground: ThemeColorPicker = ["#EDEFEF", "#242424"]
    
    
    /////////////////
    //  CG COLORS  //
    /////////////////
    
    /* CG version of mainTint */
    static let mainTintCgColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#446CB3", "#6FACFA")
    
    /* CG version of copyrightText */
    static let copyrightTextCgColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#555555", "#7E7E7E")
    
    /* Icon layer borderColor */
    static let borderCgColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#C7C7CC", "#1E1E1E")
    
    /* CG version of tableViewBackgroundColor */
    static let tableViewCGBackgroundColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#EFEFF4", "#121212")
    
    /* Hardcoded Apple's UIButton selected color */
    static let buttonBorderCgColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#D0D0D4", "#272727")
    
    /* Arrow Layer Stroke Color */
    static let arrowLayerStrokeCGColor: ThemeCGColorPicker = ThemeCGColorPicker(colors: "#000000CC", "#FFFFFFCC")
}
