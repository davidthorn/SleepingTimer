//
//  ServiceContainer.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Foundation

/// Dependency container for app-level services.
public protocol ServiceContainerProtocol: Sendable {
    /// Sleep data store dependency.
    var sleepStore: any SleepStoreProtocol { get }
}

/// Concrete dependency container implementation.
public struct ServiceContainer: ServiceContainerProtocol, Sendable {
    /// Sleep data store dependency.
    public let sleepStore: any SleepStoreProtocol

    /// Creates a container with required service dependencies.
    public init(sleepStore: any SleepStoreProtocol) {
        self.sleepStore = sleepStore
    }
}
