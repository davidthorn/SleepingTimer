//
//  ServiceContainer.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Foundation

/// Concrete dependency container implementation.
public struct ServiceContainer: ServiceContainerProtocol, Sendable {
    /// Sleep data store dependency.
    public let sleepStore: SleepStoreProtocol

    /// Creates a container with required service dependencies.
    public init(sleepStore: SleepStoreProtocol) {
        self.sleepStore = sleepStore
    }
}
