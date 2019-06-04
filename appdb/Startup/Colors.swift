//
//  Colors.swift
//  appdb
//
//  Created by ned on 11/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import SwiftTheme

/* First is light theme, second is Dark theme hex, third is darker theme (oled). */

enum Color {

    /////////////////
    //  UI COLORS  //
    /////////////////

    /* Blue main tint, may not be final */
    static let mainTint: ThemeColorPicker = ["#446CB3", "#6FACFA", "#6FACFA"]

    /* Slightly darker main tint for 'Authorize' cell background */
    static let slightlyDarkerMainTint: ThemeColorPicker = ["#446CB3", "#3A6EB0", "#3A6EB0"]

    /* Darker main tint for pressed 'Authorize' cell state */
    static let darkMainTint: ThemeColorPicker = ["#486A92", "#2C5285", "#2C5285"]

    /* Category, author, seeAll button */
    static let darkGray: ThemeColorPicker = ["#6F7179", "#9c9c9c", "#9c9c9c"]

    /* Background color, used for tableView and fill spaces */
    static let tableViewBackgroundColor: ThemeColorPicker = ["#EFEFF4", "#121212", "#000000"]

    /* TableView separator color */
    static let borderColor: ThemeColorPicker = ["#C7C7CC", "#373737", "#373737"]

    /* Error message, copyright text */
    static let copyrightText: ThemeColorPicker = ["#555555", "#7E7E7E", "#7E7E7E"]

    /* Slightly different than background, used for tableView cells */
    static let veryVeryLightGray: ThemeColorPicker = ["#FDFDFD", "#1E1E1E", "#000000"]

    /* Black for light theme, white for dark theme */
    static let title: ThemeColorPicker = ["#121212", "#F8F8F8", "#F8F8F8"]

    /* White for light theme, black for dark theme */
    static let invertedTitle: ThemeColorPicker = ["#F8F8F8", "#121212", "#121212"]

    /* Cell selection overlay color */
    static let cellSelectionColor: ThemeColorPicker = ["#D8D8D8", "#383838", "#383838"]

    /* Matches translucent barStyle color */
    static let popoverArrowColor: ThemeColorPicker = ["#F6F6F7", "#161616", "#161616"]

    /* Details+Information parameter color */
    static let informationParameter: ThemeColorPicker = ["#9A9898", "#C5C3C5", "#C5C3C5"]

    /* A light gray used for error message in Downloads */
    static let lightErrorMessage: ThemeColorPicker = ["#9A9898", "#3D3D3D", "#363636"]

    /* Green for INSTALL button and verified crackers */
    static let softGreen: ThemeColorPicker = ["#00B600", "#00B600", "#00B600"]

    /* Red for non verified crackers button and 'Deauthorize' cell */
    static let softRed: ThemeColorPicker = ["#D32F2F", "#D32F2F", "#D32F2F"]

    /* Dark red for pressed 'Deauthorize' cell state */
    static let darkRed: ThemeColorPicker = ["#A32F2F", "#6A2121", "#6A2121"]

    /* Gray for timestamp in device status cell */
    static let timestampGray: ThemeColorPicker = ["#AAAAAA", "#AAAAAA", "#AAAAAA"]

    /* Background for bulletins */
    static let easyBulletinBackground: ThemeColorPicker = ["#EDEFEF", "#242424", "#242424"]

    /* Hardcoded Apple's UIButton selected color */
    static let buttonBorderColor: ThemeColorPicker = ["#D0D0D4", "#272727", "#272727"]

    /* Almost full white, used for authorize cell text color */
    static let dirtyWhite: ThemeColorPicker = ["#F8F8F8", "#F8F8F8", "#F8F8F8"]

    /* Search suggestions, color for text */
    static let searchSuggestionsTextColor: ThemeColorPicker = ["#777777", "#828282", "#828282"]

    /* Search suggestions, color for search icon */
    static let searchSuggestionsIconColor: ThemeColorPicker = ["#c6c6c6", "#7c7c7c", "#7c7c7c"]

    /* "...more" text color in ElasticLabel */
    static let moreTextColor = ["#4E7DD0", "#649EE6", "#649EE6"]

    /* Text color used in navigation bar title */
    static let navigationBarTextColor = ["#121212", "#F8F8F8", "#F8F8F8"]

    /////////////////
    //  CG COLORS  //
    /////////////////

    /* CG version of mainTint */
    static let mainTintCgColor = ThemeCGColorPicker(colors: "#446CB3", "#6FACFA", "#6FACFA")

    /* CG version of copyrightText */
    static let copyrightTextCgColor = ThemeCGColorPicker(colors: "#555555", "#7E7E7E", "#7E7E7E")

    /* Icon layer borderColor */
    static let borderCgColor = ThemeCGColorPicker(colors: "#C7C7CC", "#1E1E1E", "#1E1E1E")

    /* CG version of tableViewBackgroundColor */
    static let tableViewCGBackgroundColor = ThemeCGColorPicker(colors: "#EFEFF4", "#121212", "#121212")

    /* Hardcoded Apple's UIButton selected color */
    static let buttonBorderCgColor = ThemeCGColorPicker(colors: "#D0D0D4", "#272727", "#272727")

    /* Arrow Layer Stroke Color */
    static let arrowLayerStrokeCGColor = ThemeCGColorPicker(colors: "#000000CC", "#FFFFFFCC", "#FFFFFFCC")
}
