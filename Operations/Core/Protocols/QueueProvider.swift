//
//  QueueProvider.swift
//  Operations
//
//  Created by Denys on 3/25/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

public protocol QueueProvider: AnyObject {
    var queue: OperationQueue { get }
}
