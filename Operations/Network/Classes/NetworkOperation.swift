//
//  NetworkOperation.swift
//  Operations
//
//  Created by Denys on 4/2/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

final class NetworkOperation: CoreOperation<RequestConvertible, Data> {

    // MARK: - Properties
    private var manager: URLSession
    private var dataTask: URLSessionDataTask!
    
    // MARK: - Init / Deinit methods
    init(in queue: OperationQueue, request: RequestConvertible, session: URLSession) {
        manager = session
        super.init(in: queue)
        
        input = .success(request)
    }
    
    // MARK: - Lifecycle
    override func main() {
        guard canProceed() else { return }
        
        _ = input.map(execute)
    }
    
    override func cancel() {
        super.cancel()
        
        dataTask?.cancel()
    }
}

// MARK: - Private methods
extension NetworkOperation {
    
    private func execute(_ urlRequest: RequestConvertible) {
        dataTask = manager.request(urlRequest) { responseData, response, error in
            
            defer { self.finished() }
            
            if let urlResponse = response as? HTTPURLResponse,
                !Constants.validStatusCodes.contains(urlResponse.statusCode) {
                self.output = .failure(NetworkError.unacceptableStatusCode(code: urlResponse.statusCode))
                return
            }
            
            guard let data = responseData,
                error == nil else {
                    self.output = .failure(NetworkError.invalidResponse(error: error))
                    return
            }
            
            self.output = .success(data)
        }
    }
}
