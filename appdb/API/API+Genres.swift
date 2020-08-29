//
//  API+Genres.swift
//  appdb
//
//  Created by ned on 11/01/2017.
//  Copyright © 2017 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension API {

    // MARK: - Genres

    static func listGenres(completion:@escaping () -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.listGenres.rawValue, "lang": languageCode], headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)

                    var genres: [Genre] = []
                    let data = json["data"]

                    // Default genres
                    genres.append(Genre(category: "ios", id: "0", name: "All Categories".localized()))
                    genres.append(Genre(category: "cydia", id: "0", name: "All Categories".localized()))
                    genres.append(Genre(category: "books", id: "0", name: "All Categories".localized()))

                    // Cydia genres
                    for (key, value):(String, JSON) in data["cydia"] {
                        genres.append(
                            Genre(category: "cydia", id: key, name: value["name"].stringValue, amount: value["content_amount"].stringValue)
                        )
                    }

                    // iOS Genres
                    for (key, value):(String, JSON) in data["ios"] {
                        genres.append(
                            Genre(category: "ios", id: key, name: value["name"].stringValue, amount: value["content_amount"].stringValue)
                        )
                    }

                    // Books Genres
                    for (key, value):(String, JSON) in data["books"] {
                        genres.append(
                            Genre(category: "books", id: key, name: value["name"].stringValue, amount: value["content_amount"].stringValue)
                        )
                    }

                    // Remove delete genres
                    if let index = Preferences.genres.firstIndex(where: { !genres.contains($0) }) {
                        Preferences.remove(.genres, at: index)
                    }

                    guard !genres.isEmpty else { completion(); return }

                    // Save genres
                    for (index, var genre) in genres.enumerated() {
                        guard let type = ItemType(rawValue: genre.category) else { return }

                        if let index = Preferences.genres.firstIndex(where: { $0.compound == genre.compound }) {
                            // Genre exists
                            if Preferences.genres[index].icon.isEmpty {
                                getIcon(id: genre.id, type: type, completion: { icon in
                                    genre.icon = icon
                                    Preferences.remove(.genres, at: index)
                                    Preferences.append(.genres, element: genre)
                                })
                            }
                        } else {
                            // Genre does not exist
                            getIcon(id: genre.id, type: type, completion: { icon in
                                genre.icon = icon
                                Preferences.append(.genres, element: genre)
                            })
                        }

                        if index == genres.count - 1 {
                            completion()
                        }
                    }

                case .failure:
                    break
                }
            }
    }

    static func getIcon(id: String, type: ItemType, completion:@escaping (String) -> Void) {
        AF.request(endpoint, parameters: ["action": Actions.search.rawValue, "type": type.rawValue, "genre": id, "order": Order.all.rawValue], headers: headers)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(json["data"][0]["image"].stringValue)
                case .failure:
                    completion("")
                }
            }
    }

    static func categoryFromId(id: String, type: ItemType) -> String {
        if let genre = Preferences.genres.first(where: { $0.category == type.rawValue && $0.id == id }) {
            return genre.name
        } else {
            return ""
        }
    }

    static func idFromCategory(name: String, type: ItemType) -> String {
        if let genre = Preferences.genres.first(where: { $0.category == type.rawValue && $0.name == name }) {
            return genre.id
        } else {
            return ""
        }
    }
}
