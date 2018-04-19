//
//  API+Genres.swift
//  appdb
//
//  Created by ned on 11/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//


import Alamofire
import RealmSwift
import SwiftyJSON

extension API {
    
    // MARK: - Genres
    
    static func listGenres() {
        
        Alamofire.request(endpoint, parameters: ["action": Actions.listGenres.rawValue, "lang": languageCode], headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    
                    var genres: [Genre] = []
                    let data = json["data"]
                    
                    // Cydia genres
                    for (key, value):(String, JSON) in data["cydia"] {
                        genres.append(Genre(category: "cydia", id: key, name: value.stringValue))
                    }
                    
                    // iOS Genres
                    for (key, value):(String, JSON) in data["ios"] {
                        genres.append(Genre(category: "ios", id: key, name: value.stringValue))
                    }
                    
                    // Books Genres
                    for (key, value):(String, JSON) in data["books"] {
                        genres.append(Genre(category: "books", id: key, name: value.stringValue))
                    }
                    
                    do {
                        try realm.write {
                            
                            // Marking '666' for future comparison
                            for object in realm.objects(Genre.self) { object.id = "666" }
                            
                            // Using this ugly 'create()' method so that icon url is preserved at next launch
                            realm.create(Genre.self, value: ["id": "0", "name": "All Categories".localized(), "category": "ios", "compound": "0-ios"], update: true)
                            realm.create(Genre.self, value: ["id": "0", "name": "All Categories".localized(), "category": "cydia", "compound": "0-cydia"], update: true)
                            realm.create(Genre.self, value: ["id": "0", "name": "All Categories".localized(), "category": "books", "compound": "0-books"], update: true)
                            for genre in genres {
                                realm.create(Genre.self, value: ["id": genre.id, "name": genre.name, "category": genre.category, "compound": "\(genre.id)-\(genre.category)"], update: true)
                            }

                            // Delete any old category that was deleted from appdb
                            realm.delete(realm.objects(Genre.self).filter("id = '666'"))
                            
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
                    
                case .failure:
                    break
                }
                
        }
    }
    
    static func getIcon(id: String, type: ItemType) {
        if let cat = realm.objects(Genre.self).filter("category = %@ AND id = %@", type.rawValue, id).first {
            Alamofire.request(endpoint, parameters: ["action": Actions.search.rawValue, "type": type.rawValue, "genre": id, "order": Order.all.rawValue], headers: headers)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        try! realm.write { cat.icon = json["data"][0]["image"].stringValue }
                    case .failure:
                        break
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
