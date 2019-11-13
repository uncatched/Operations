//
//  DecodeOperation.swift
//  Operations
//
//  Created by Denys on 4/2/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

final class DecodeOperation<Entity: Decodable>: CoreOperation<Data, Entity> {
    
    // MARK: - Properties
    private let jsonDecoder: JSONDecoder
    private let keyPath: String?
    
    // MARK: - Init / Deinit methods
    init(in queue: OperationQueue, decoder: JSONDecoder = JSONDecoder(), path: String? = nil) {
        jsonDecoder = decoder
        keyPath = path
        super.init(in: queue)
    }
    
    // MARK: - Life Cycle
    override public func main() {
        guard canProceed() else { return }
        
        output = input.flatMap(decode)
        finished()
    }
}

// MARK: - Private methods
extension DecodeOperation {
    
    private func decode(data: Data) -> Result<Entity, Error> {
        if let keyPath = keyPath {
            return Result { try jsonDecoder.decode(Entity.self, from: data, keyPath: keyPath) }
        } else {
            return Result { try jsonDecoder.decode(Entity.self, from: data) }
        }
    }
}
