//
//  URLSession.swift
//  Operations
//
//  Created by Denys on 4/2/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

typealias URLRequestResponse = (Data?, URLResponse?, Error?) -> Void

extension URLSession {
    
    func request(_ urlRequest: RequestConvertible, completion: @escaping URLRequestResponse) -> URLSessionDataTask? {
        do {
            let request = try urlRequest.asURLRequest()
            let originalTask = dataTask(with: request, completionHandler: completion)
            
            originalTask.resume()
            
            return originalTask
        } catch {
            completion(nil, nil, error)
            return nil
        }
    }
}
