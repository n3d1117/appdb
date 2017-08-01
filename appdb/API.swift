//
//  API.swift
//  appdb
//
//  Created by ned on 15/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift
import SwiftyJSON

protocol Meta {
    static func type() -> ItemType
}

enum ItemType: String {
    case ios = "ios"
    case books = "books"
    case cydia = "cydia"
}

enum Order: String {
    case added = "added"
    case day = "clicks_day"
    case week = "clicks_week"
    case month = "clicks_month"
    case year = "clicks_year"
    case all = "clicks_all"
}

enum Price: String {
    case all = "0"
    case paid = "1"
    case free = "2"
}

enum Actions: String {
    case search = "search"
    case listGenres = "list_genres"
    case promotions = "promotions"
    case getLinks = "get_links"
}

struct API {
    
    static let realm = try! Realm()
    static let endpoint = "https://api.appdb.store/v1.2/"
    static let languageCode = Locale.current.languageCode ?? "en"
    static let headers: HTTPHeaders = ["User-Agent": "appdb iOS Client v\(Global.appVersion)"]
    
}
