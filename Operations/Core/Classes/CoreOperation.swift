//
//  CoreOperation.swift
//  Operations
//
//  Created by Denys on 3/25/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

class CoreOperation<Input, Output>: Operation {
    
    // MARK: - Public properties
    var input: Result<Input, Error> {
        get {
            defer { inputLock.unlock() }
            inputLock.lock()
            return inputValue
        }
        set {
            defer { inputLock.unlock() }
            inputLock.lock()
            inputValue = newValue
        }
    }
    var output: Result<Output, Error> {
        get {
            defer { outputLock.unlock() }
            outputLock.lock()
            return outputValue
        }
        set {
            defer { outputLock.unlock() }
            outputLock.lock()
            outputValue = newValue
        }
    }
    
    var state: OperationState = .ready {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    var completed: (() -> Void) = {}
    
    // MARK: - Overriden properties
    override var isReady: Bool {
        return state == .ready
    }
    
    override public final var isExecuting: Bool {
        return state == .executing
    }
    
    override public final var isFinished: Bool {
        return state == .finished
    }
    
    override public final var isCancelled: Bool {
        return state == .cancelled
    }
    
    // MARK: - Private properties
    private(set) var queue: OperationQueue
    private let inputLock = NSLock()
    private let outputLock = NSLock()
    private var inputValue: Result<Input, Error> = .failure(OperationError.emptyInput)
    private var outputValue: Result<Output, Error> = .failure(OperationError.emptyOutput)
    
    // MARK: - Init / Deinit methods
    init(in operationQueue: OperationQueue) {
        queue = operationQueue
    }
    
    // MARK: - Lifecycle
    override public final func start() {
        guard canProceed() else { return }
        
        main()
    }
    
    override open func main() {
        finished()
    }
    
    override open func cancel() {
        guard !isCancelled else { return }
        
        output = input.flatMap(cancelled)
        state = .cancelled
        
        super.cancel()
    }
}

// MARK: - Public methods
extension CoreOperation {
    
    func finished() {
        completed()
        state = .finished
    }
    
    func canProceed() -> Bool {
        guard !isCancelled else {
            finished()
            return false
        }
        
        state = .executing
        return true
    }
}

// MARK: - Private methods
extension CoreOperation {
    
    private func cancelled(_ input: Input) -> Result<Output, Error> {
        return .failure(OperationError.cancelled)
    }
}

// MARK: - Then
extension CoreOperation {
    
    // MARK: - Public methods
    func then<U>(_ op: CoreOperation<Output, U>) -> CoreOperation<Output, U> {
        op.addDependency(self)
        completed = { [unowned self] in
            op.input = self.output
        }
    
        return op
    }
    
    func then<T, U>(_ op: CoreOperation<T, U>) -> CoreOperation<T, U> {
        op.addDependency(self)
        return op
    }
}
