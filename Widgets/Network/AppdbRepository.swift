//
//  AppdbRepository.swift
//  WidgetsExtension
//
//  Created by ned on 08/03/21.
//  Copyright © 2021 ned. All rights reserved.
//

import Foundation
import Combine

class AppdbRepository: Repository {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension AppdbRepository {
    struct ErrorResponse: Decodable {
        let error: String
    }
}

extension AppdbRepository {
    func fetchAPIResource<Resource>(_ resource: Resource) -> AnyPublisher<Resource.Response, APIError> where Resource: APIResource {
        guard let url = resource.url else {
            let error = APIError.invalidRequest(description: "Invalid `resource.url`: \(String(describing: resource.url))")
            return Fail(error: error).eraseToAnyPublisher()
        }
        return fetch(url: url)
            .flatMap(decode)
            .eraseToAnyPublisher()
    }

    func decode<Response>(data: Data) -> AnyPublisher<Response, APIError> where Response: Decodable {
        if let response = try? JSONDecoder().decode(Response.self, from: data) {
            return Just(response).setFailureType(to: APIError.self).eraseToAnyPublisher()
        }
        do {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            return Fail(error: .invalidRequest(description: errorResponse.error)).eraseToAnyPublisher()
        } catch {
            return Fail(error: .unknown).eraseToAnyPublisher()
        }
    }
}

struct AppdbSearchResource: APIResource {
    let serverPath = "api.dbservices.to"
    let methodPath: String
    var queryItems: [URLQueryItem]?

    init(_ contentType: ContentType, _ sortOrder: SortOrder, _ contentPrice: ContentPrice) {
        methodPath = "/v1.3/"
        queryItems = [
            URLQueryItem(name: "action", value: "search"),
            URLQueryItem(name: "type", value: type(from: contentType)),
            URLQueryItem(name: "price", value: price(from: contentPrice)),
            URLQueryItem(name: "order", value: order(from: sortOrder))
        ]
    }
}

extension AppdbSearchResource {
    struct Response: Decodable {
        let success: Bool
        let errors: [String]
        let data: [Content]
    }
}

struct AppdbNewsResource: APIResource {
    let serverPath = "api.dbservices.to"
    let methodPath: String
    var queryItems: [URLQueryItem]?

    init() {
        methodPath = "/v1.3/"
        queryItems = [
            URLQueryItem(name: "action", value: "get_pages"),
            URLQueryItem(name: "category", value: "news"),
            URLQueryItem(name: "length", value: "8")
        ]
    }
}

extension AppdbNewsResource {
    struct Response: Decodable {
        let success: Bool
        let errors: [String]
        let data: [News]
    }
}
