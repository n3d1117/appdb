//
//  DeviceStatusItem.swift
//  appdb
//
//  Created by ned on 16/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import ObjectMapper
import SwiftyJSON

class DeviceStatusItem: Mappable, Matchable {
    
    @objc dynamic var uuid = ""
    @objc dynamic var added = ""
    @objc dynamic var params = ""
    @objc dynamic var acknowledged = ""
    @objc dynamic var status = ""
    @objc dynamic var type = ""
    
    @objc dynamic var title = ""
    @objc dynamic var bundleId = ""
    @objc dynamic var purpose = ""
    @objc dynamic var statusShort = ""
    @objc dynamic var statusText = ""

    convenience required init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        uuid             <- map["uuid"]
        added            <- map["added"]
        params           <- map["params"]
        acknowledged     <- map["acknowledged"]
        status           <- map["status"]
        type             <- map["type"]
        
        added = added.unixToDetailedString
        acknowledged = acknowledged.unixToDetailedString
        
        if let data = params.data(using: .utf8), let params = try? JSON(data: data) {
            title = params["link_data"]["title"].stringValue
            bundleId = params["link_data"]["bundle_id"].stringValue
            purpose = params["purpose"].stringValue
            statusShort = params["sign"]["status"].stringValue
            statusText = params["sign"]["status_text"].stringValue
            if statusText.hasSuffix("\n") { statusText = statusText.trimTrailingWhitespace() }
        }
        
    }
    
    func match(with object: Any) -> Match {
        guard let status = object as? DeviceStatusItem else { return .none }
        
        if uuid == status.uuid {
            if statusText == status.statusText {
                return .equal
            } else {
                return .change // Same uuid, but not statusText
            }
        } else {
            return .none
        }
    }
    
}
