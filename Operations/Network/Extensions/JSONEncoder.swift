//
//  JSONEncoder.swift
//  Operations
//
//  Created by Denys on 4/2/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

extension JSONEncoder {
    
    enum HTTPHeaders: String {
        case contentType = "Content-Type"
        case accept = "Accept"
        case authorization = "Authorization"
        case acceptEncoding = "Accept-Encoding"
        
        func value() -> String {
            switch self {
            default: return "application/json"
            }
        }
    }
    
    func encode(_ request: URLRequest, with data: Data? = nil) throws -> URLRequest {
        var urlRequest = request
        
        if urlRequest.value(forHTTPHeaderField: HTTPHeaders.contentType.rawValue) == nil {
            urlRequest.setValue(HTTPHeaders.contentType.value(), forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
            urlRequest.setValue(HTTPHeaders.accept.value(), forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        }
        
        guard let json = data else { return urlRequest }
        urlRequest.httpBody = json
        
        return urlRequest
    }
}
