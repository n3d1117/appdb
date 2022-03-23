//
//  APIResponseError.swift
//  WidgetsExtension
//
//  Created by ned on 23/03/22.
//  Copyright © 2022 ned. All rights reserved.
//

import Foundation

struct APIResponseError: Decodable {

    let code: String
    let translated: String
}
