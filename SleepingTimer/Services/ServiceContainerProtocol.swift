//
//  ServiceContainerProtocol.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Foundation

/// Dependency container protocol for app-level services.
public protocol ServiceContainerProtocol: Sendable {
    /// Sleep data store dependency.
    var sleepStore: SleepStoreProtocol { get }
}
