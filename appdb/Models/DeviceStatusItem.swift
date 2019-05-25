//
//  DeviceStatusItem.swift
//  appdb
//
//  Created by ned on 16/05/2018.
//  Copyright © 2018 ned. All rights reserved.
//

import ObjectMapper
import SwiftyJSON

struct DeviceStatusItem: Mappable, Matchable {
    
    init?(map: Map) { }
    
    var uuid: String = ""
    var added: String = ""
    var params: String = ""
    var acknowledged: String = ""
    var status: String = ""
    var type: String = ""
    var timestamp: String = ""
    var title: String = ""
    var bundleId: String = ""
    var purpose: String = ""
    var statusShort: String = ""
    var statusText: String = ""
    var linkId: String = ""
    
    mutating func mapping(map: Map) {
        uuid             <- map["uuid"]
        added            <- map["added"]
        params           <- map["params"]
        acknowledged     <- map["acknowledged"]
        status           <- map["status"]
        type             <- map["type"]
        
        acknowledged = acknowledged.unixToDetailedString
        timestamp = Global.formattedTimeFromNow(from: added.unixToDate)
        
        if let data = params.data(using: .utf8), let params = try? JSON(data: data) {
            title = params["link_data"]["title"].stringValue
            bundleId = params["link_data"]["bundle_id"].stringValue
            linkId = params["link_data"]["id"].stringValue
            purpose = params["purpose"].stringValue
            statusShort = params["sign"]["status"].stringValue
            statusText = params["sign"]["status_text"].stringValue
            if statusText.hasSuffix("\n") { statusText = statusText.trimTrailingWhitespace() }
        }
        
    }
    
    func match(with object: Any) -> Match {
        guard let status = object as? DeviceStatusItem else { return .none }
        
        if uuid == status.uuid {
            if statusText == status.statusText && timestamp == status.timestamp {
                return .equal
            } else {
                return .change // Same uuid, but not statusText or timestamp
            }
        } else {
            return .none
        }
    }
    
}
