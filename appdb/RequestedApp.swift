//
//  RequestedApp.swift
//  appdb
//
//  Created by ned on 22/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

struct RequestedApp: Matchable {
    
    var linkId = ""
    var id = ""
    var type = ""
    var name = ""
    var status = ""
    var image = ""
    var bundleId = ""
    
    init(linkId: String, id: String, type: ItemType, name: String, image: String, bundleId: String, status: String = "") {
        self.linkId = linkId
        self.id = id
        self.type = type.rawValue
        self.name = name
        self.image = image
        self.bundleId = bundleId
        self.status = status
    }
    
    func match(with object: Any) -> Match {
        guard let app = object as? RequestedApp else { return .none }
        guard linkId == app.linkId else { return .none }
        return status == app.status ? .equal : .change
    }
}
