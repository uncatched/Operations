//
//  NetworkError.swift
//  Operations
//
//  Created by Denys on 4/2/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case noInternetConnection
    case invalidResponse(error: Error?)
    case unacceptableStatusCode(code: Int)
}
