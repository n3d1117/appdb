//
//  Preferences.swift
//  appdb
//
//  Created by ned on 27/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import RealmSwift

class Preferences : Object {

    dynamic var theme : Int = 0
    dynamic var isFirstLaunch : Bool = false
    
}
