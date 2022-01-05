//
//  API.swift
//  appdb
//
//  Created by ned on 15/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import Alamofire
import SwiftyJSON
import Localize_Swift

enum API {
    static let endpoint = "https://api.dbservices.to/v1.4/"
    static let statusEndpoint = "https://status.dbservices.to/API/v1.0/"
    static let itmsHelperEndpoint = "https://dbservices.to/manifest.php"

    static var languageCode: String {
        Localize.currentLanguage()
    }

    static let headers: HTTPHeaders = ["User-Agent": "appdb iOS Client v\(Global.appVersion)"]

    static var headersWithCookie: HTTPHeaders {
        guard Preferences.deviceIsLinked else { return headers }
        return [
            "User-Agent": "appdb iOS Client v\(Global.appVersion)",
            "Cookie": "lt=\(Preferences.linkToken)"
        ]
    }
}

enum DeviceType: String {
    case iphone
    case ipad
}

enum ItemType: String, Codable {
    case ios = "ios"
    case books = "books"
    case cydia = "cydia"
    case myAppstore = "MyAppStore"
}

enum Order: String, CaseIterable {
    case added = "added"
    case day = "clicks_day"
    case week = "clicks_week"
    case month = "clicks_month"
    case year = "clicks_year"
    case all = "clicks_all"

    var pretty: String {
        switch self {
        case .added: return "Recently Uploaded".localized()
        case .day: return "Popular Today".localized()
        case .week: return "Popular This Week".localized()
        case .month: return "Popular This Month".localized()
        case .year: return "Popular This Year".localized()
        case .all: return "Popular All Time".localized()
        }
    }

    var associatedImage: String {
        switch self {
        case .added: return "clock"
        case .day: return "calendar"
        case .week: return "calendar"
        case .month: return "calendar"
        case .year: return "calendar"
        case .all: return "flame"
        }
    }
}

enum Price: String, CaseIterable {
    case all = "0"
    case paid = "1"
    case free = "2"

    var pretty: String {
        switch self {
        case .all: return "Any Price".localized()
        case .paid: return "Paid".localized()
        case .free: return "Free".localized()
        }
    }

    var associatedImage: String {
        switch self {
        case .all: return "cart"
        case .paid: return "dollarsign.circle"
        case .free: return "giftcard"
        }
    }
}

enum Actions: String {
    case search = "search"
    case listGenres = "list_genres"
    case promotions = "promotions"
    case getLinks = "get_links"
    case getPages = "get_pages"
    case newsCategory = "news"
    case link = "link"
    case getLinkCode = "get_link_code"
    case getConfiguration = "get_configuration"
    case configure = "configure"
    case getStatus = "get_status"
    case clear = "clear"
    case fix = "fix_command"
    case retry = "retry_command"
    case install = "install"
    case customInstall = "custom_install"
    case report = "report"
    case checkRevoke = "is_apple_fucking_serious"
    case getUpdatesTicket = "get_update_ticket"
    case getUpdates = "get_updates"
    case getIpas = "get_ipas"
    case deleteIpa = "delete_ipa"
    case addIpa = "add_ipa"
    case analyzeIpa = "get_ipa_analyze_jobs"
    case createPublishRequest = "create_publish_request"
    case getPublishRequests = "get_publish_requests"
    case validatePro = "validate_voucher"
    case activatePro = "activate_pro"
    case emailLinkCode = "email_link_code"
    case getAppdbAppsBundleIdsTicket = "get_appdb_apps_bundle_ids_ticket"
    case getAppdbAppsBundleIds = "get_appdb_apps_bundle_ids"
    case processRedirect = "process_redirect"
    case getAllDevices = "get_all_devices"
}

enum ConfigurationParameters: String {
    case appsync = "params[appsync]"
    case ignoreCompatibility = "params[ignore_compatibility]"
    case askForOptions = "params[ask_for_installation_options]"
    case clearDevEntity = "params[clear_developer_entity]"
    case disableProtectionChecks = "params[disable_protection_checks]"
    case enableIapPatch = "params[enable_inapp_patch]"
    case forceDisablePRO = "params[is_pro_disabled]"
    case enableTrainer = "params[enable_trainer]"
    case signingIdentityType = "params[signing_identity_type]"
    case optedOutFromEmails = "params[is_opted_out_from_emails]"
}
