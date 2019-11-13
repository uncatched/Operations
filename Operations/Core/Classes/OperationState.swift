//
//  OperationState.swift
//  Operations
//
//  Created by Denys on 3/25/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

enum OperationState: String {
    case ready = "isReady"
    case executing = "isExecuting"
    case finished = "isFinished"
    case cancelled = "isCancelled"
}
