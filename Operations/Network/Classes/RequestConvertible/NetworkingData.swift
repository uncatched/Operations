//
//  NetworkingData.swift
//  Operations
//
//  Created by Denys on 4/2/19.
//  Copyright © 2019 Litvinskii Denis. All rights reserved.
//

import Foundation

final class NetworkingData {
    public static let shared = NetworkingData()
    
    public var networkingAPIHost: URL?
    public var networkingHeaders: (() -> [String: String])?
}
