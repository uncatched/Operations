//
//  JSONDecoder+KeyPath.swift
//  Operations
//
//  Created by Denys on 4/2/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

extension JSONDecoder {
    
    enum DecodeError: Error {
        case emptyData
    }
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data, keyPath: String) throws -> T {
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        if let nestedJson = (jsonObject as AnyObject).value(forKeyPath: keyPath) as? [Any] {
            let nestedJsonData = try JSONSerialization.data(withJSONObject: nestedJson)
            return try decode(type, from: nestedJsonData)
        } else if let nestedJson = (jsonObject as AnyObject).value(forKey: keyPath) as? [String: Any] {
            let nestedJsonData = try JSONSerialization.data(withJSONObject: nestedJson)
            return try decode(type, from: nestedJsonData)
        } else {
            throw DecodeError.emptyData
        }
    }
}
