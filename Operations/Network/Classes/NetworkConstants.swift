//
//  NetworkConstants.swift
//  Operations
//
//  Created by Denys on 4/2/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

struct Constants {
    static let validStatusCodes = 200..<300
    static let contentTypeHeaderKey = "Content-Type"
    
    struct Multipart {
        static func multipartContentType(with boundary: String) -> String {
            return "multipart/form-data; boundary=\(boundary)"
        }
        
        static func boundaryHeaderDelimiter(with boundary: String) -> String {
            return "--\(boundary)\r\n"
        }
        
        static func boundaryFooterDelimiter(with boundary: String) -> String {
            return "\r\n--\(boundary)--\r\n"
        }
        
        static func multipartContentDisposition(name: String, filename: String) -> String {
            return "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n"
        }
        
        static func multipartMIMEContentType(with mimeType: String) -> String {
            return "Content-Type: \(mimeType)\r\n\r\n"
        }
    }
}
