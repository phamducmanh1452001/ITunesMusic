//
//  NetworkMonitor.swift
//  ITunesMusic
//
//  Created by Manh Blue on 11/28/20.
//  Copyright © 2020 Manh Blue. All rights reserved.
//

import UIKit
import Network


final class NetWorkMonitor {
    static let shared = NetWorkMonitor()
    
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    
    public private(set) var isConnected: Bool = false
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
}

