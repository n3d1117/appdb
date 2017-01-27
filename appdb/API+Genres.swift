//
//  API+Genres.swift
//  appdb
//
//  Created by ned on 11/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import RealmSwift
import SwiftyJSON

extension API {
    
    // MARK: - Genres
    
    static func listGenres(completion: @escaping (_ success : Bool) -> Void) {
        
        Alamofire.request(endpoint, parameters: ["action": Actions.listGenres.rawValue])
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    var tmp : [Genre] = []
                    
                    // Cydia genres
                    for (key, value):(String, JSON) in json["data"]["cydia"] {
                        tmp.append(Genre(category: "cydia", id: key, name: value.stringValue))
                    }
                    
                    // iOS Genres
                    for (key, value):(String, JSON) in json["data"]["ios"] {
                        tmp.append(Genre(category: "ios", id: key, name: value.stringValue))
                    }
                    
                    // Books Genres
                    for (key, value):(String, JSON) in json["data"]["books"] {
                        tmp.append(Genre(category: "books", id: key, name: value.stringValue))
                    }
                    
                    do {
                        try realm.write {
                            realm.create(Genre.self, value: ["id": "0", "name": "All Categories", "category": "ios", "compound": "0-ios"], update: true)
                            realm.create(Genre.self, value: ["id": "0", "name": "All Categories", "category": "cydia", "compound": "0-cydia"], update: true)
                            realm.create(Genre.self, value: ["id": "0", "name": "All Categories", "category": "books", "compound": "0-books"], update: true)
                            for genre in tmp {
                                realm.create(Genre.self, value: ["id": genre.id, "name": genre.name, "category": genre.category, "compound": "\(genre.id)-\(genre.category)"], update: true)
                            }
                        }
                    } catch let e as NSError {
                        print(e.localizedDescription)
                    }
                    
                    // Get icons for categories (only once)
                    for genre in realm.objects(Genre.self).filter("category = 'ios' AND icon = ''") {
                        getIcon(id: genre.id, type: .ios)
                    }
                    for genre in realm.objects(Genre.self).filter("category = 'cydia' AND icon = ''") {
                        getIcon(id: genre.id, type: .cydia)
                    }
                    for genre in realm.objects(Genre.self).filter("category = 'books' AND icon = ''") {
                        getIcon(id: genre.id, type: .books)
                    }
                    
                    completion(true)
                    
                case .failure(let error):
                    print((error as NSError).localizedDescription)
                    completion(false)
                }
                
        }
    }
    
    static func getIcon(id: String, type: ItemType) {
        if let cat = realm.objects(Genre.self).filter("category = %@ AND id = %@", type.rawValue, id).first {
            Alamofire.request(endpoint, parameters: ["action": Actions.search.rawValue, "type": type.rawValue, "genre": id, "order": "clicks_all"])
                .responseJSON { response in
                    //print(response.request!.url!.absoluteString)
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        try! realm.write { cat.icon = json["data"][0]["image"].stringValue }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
            }
        }
    }
    
    static func categoryFromId(id: String, type: ItemType) -> String {
        if let genre = realm.objects(Genre.self).filter("category = %@ AND id = %@", type.rawValue, id).first {
            return genre.name
        } else {
            return ""
        }
    }
    
    static func idFromCategory(name: String, type: ItemType) -> String {
        if let genre = realm.objects(Genre.self).filter("category = %@ AND name = %@", type.rawValue, name).first { return genre.id }
        return ""
    }
}
