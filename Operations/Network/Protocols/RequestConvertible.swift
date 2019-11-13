//
//  RequestConvertible.swift
//  Operations
//
//  Created by Denys on 4/2/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

typealias HTTPHeaders = [String: String]

protocol RequestConvertible {
    func absoluteURL() throws -> URL
    func httpMethod() -> HTTPMethod
    func credentials() -> HTTPHeaders
    func headers() -> HTTPHeaders?
    func encode(with encoder: JSONEncoder) throws -> Data?
    func domain() throws -> URL
    func uri() throws -> String
}

// MARK: - Default implementation
extension RequestConvertible {
    
    func credentials() -> HTTPHeaders {
        return ["Auth": "SomeToken-qwe123"]
    }
    
    func domain() throws -> URL {
        guard let host = NetworkingData.shared.networkingAPIHost else {
            fatalError("Can't get API Host during making RequestConvertible request")
        }
        
        return host
    }
    
    func headers() -> HTTPHeaders? {
        var headers = HTTPHeaders()
        
        if let additionalHeaders = NetworkingData.shared.networkingHeaders?() {
            additionalHeaders.forEach { headers[$0] = $1 }
        }
        
        return headers
    }
}

// MARK: - Public methods
extension RequestConvertible {
    
    func encode(with encoder: JSONEncoder) throws -> Data? {
        return nil
    }
    
    func absoluteURL() throws -> URL {
        let absoluteURL = try domain().absoluteString + uri()
        guard let url = URL(string: absoluteURL) else { throw RequestConvertibleError.invalidAbsoluteURL }
        return url
    }
    
    func asURLRequest() throws -> URLRequest {
        return try encodedRequest()
    }
    
    func asURL() throws -> URL {
        return try absoluteURL()
    }
}

// MARK: - Private methods
extension RequestConvertible {
    
    private func json(_ encoder: JSONEncoder) throws -> Data? {
        guard let data = try encode(with: encoder) else { return nil }
        return data
    }
    
    private func encodedRequest(encoder: JSONEncoder = JSONEncoder()) throws -> URLRequest {
        let request = URLRequest(url: try absoluteURL())
        
        var encodedRequest = try JSONEncoder().encode(request, with: try json(encoder))
        encodedRequest.httpMethod = httpMethod().rawValue
        
        credentials().forEach { encodedRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        headers()?.forEach { encodedRequest.addValue($0.value, forHTTPHeaderField: $0.key) }
        
        return encodedRequest
    }
}
