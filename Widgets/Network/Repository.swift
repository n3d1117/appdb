//
//  Repository.swift
//  WidgetsExtension
//
//  Created by ned on 08/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import Combine
import Foundation

// https://github.com/pawello2222/WidgetExamples/tree/main/WidgetExtension/NetworkWidget

protocol Repository {
    var session: URLSession { get }
}

extension Repository {
    func fetch(url: URL) -> AnyPublisher<Data, APIError> {
        session.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { error in
                if error.code.rawValue == -1009 {
                    return .offline
                }
                return .network(code: error.code.rawValue, description: error.localizedDescription)
            }
            .map(\.data)
            .eraseToAnyPublisher()
    }
}

protocol APIResource {
    associatedtype Response: Decodable
    var serverPath: String { get }
    var methodPath: String { get }
    var queryItems: [URLQueryItem]? { get }
}

extension APIResource {
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = serverPath
        components.path = methodPath
        components.queryItems = queryItems
        return components.url
    }
}

extension APIResource {
    func type(from type: ContentType) -> String {
        switch type {
        case .ios: return "ios"
        case .cydia: return "cydia"
        case .books: return "books"
        case .unknown: return ""
        }
    }
    func order(from order: SortOrder) -> String {
        switch order {
        case .recent: return "added"
        case .today: return "clicks_day"
        case .week: return "clicks_week"
        case .month: return "clicks_month"
        case .year: return "clicks_year"
        case .all_time: return "clicks_all"
        case .unknown: return ""
        }
    }
    func price(from type: ContentPrice) -> String {
        switch type {
        case .any: return "0"
        case .paid: return "1"
        case .free: return "2"
        case .unknown: return ""
        }
    }
}

enum APIError: Error {
    case offline
    case network(code: Int, description: String)
    case invalidRequest(description: String)
    case unknown
}
