//
//  MultipartNetworkOperation.swift
//  Operations
//
//  Created by Denys on 10/17/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

final class MultipartNetworkOperation: CoreOperation<RequestConvertible, Data> {
    
    // MARK: - Properties
    private var data: MultipartData?
    private var backgroundCompletion: (() -> Void)?
    private var manager: URLSession!
    private var fileManager: FileManager!
    private var dataTask: URLSessionDataTask!
    
    // MARK: - Init / Deinit methods
    required init(in queue: OperationQueue, request: RequestConvertible? = nil, data: MultipartData, fileManager: FileManager = .default) {
        self.data = data
        self.fileManager = fileManager
        
        super.init(in: queue)
        if let request = request {
            input = .success(request)
        }
        
        manager = backgroundSession(with: UUID().uuidString)
    }
    
    convenience init(in queue: OperationQueue, request: RequestConvertible? = nil, data: MultipartData) {
        self.init(in: queue, request: request, data: data, fileManager: .default)
    }
    
    public init(in queue: OperationQueue, sessionIdentifier: String, backgroundCompletion: @escaping () -> Void) {
        super.init(in: queue)
        
        self.backgroundCompletion = backgroundCompletion
        manager = backgroundSession(with: sessionIdentifier)
    }
    
    // MARK: - Life Cycle
    override public func main() {
        guard canProceed(),
            data != nil else {
                return
        }
        
        _ = input.map(execute)
    }
    
    override public func cancel() {
        super.cancel()
        
        dataTask?.cancel()
    }
    
    // MARK: - Public methods
    private func execute(urlRequest: RequestConvertible) {
        guard let identifier = manager.configuration.identifier else {
            output = .failure(MultipartNetworkError.noSessionIdentifier)
            finished()
            return
        }
        
        guard let data = data else {
            output = .failure(MultipartNetworkError.multipartDataNil)
            finished()
            return
        }
        
        let fileURL = fileManager.temporaryDirectory.appendingPathComponent(identifier)
        
        do {
            try manager.upload(fileURL: fileURL, request: urlRequest, data: data)
        } catch {
            output = .failure(error)
        }
    }
}

// MARK: - Private methods
extension MultipartNetworkOperation {
    
    private func backgroundSession(with identifier: String) -> URLSession {
        let configuration: URLSessionConfiguration = .background(withIdentifier: identifier)
        configuration.sessionSendsLaunchEvents = true
        
        return URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
    }
}

// MARK: - URLSessionDelegate
extension MultipartNetworkOperation: URLSessionDelegate, URLSessionDataDelegate {
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            output = .failure(error)
        }
        
        finished()
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        output = .success(data)
        finished()
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        backgroundCompletion?()
    }
}
