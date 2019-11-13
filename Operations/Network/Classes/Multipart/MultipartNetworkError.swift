//
//  MultipartNetworkError.swift
//  Operations
//
//  Created by Denys on 10/17/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

enum MultipartNetworkError: Error {
    case noSessionIdentifier
    case multipartDataNil
}

enum MultipartBodyEncodingError: Error {
    case boundary
    case contentType
    case contentDisposition
}
