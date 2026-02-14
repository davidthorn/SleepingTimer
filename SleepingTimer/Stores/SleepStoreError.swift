//
//  SleepStoreError.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Foundation

/// Errors produced by `SleepStore` operations.
public enum SleepStoreError: LocalizedError, Sendable {
    /// Indicates an end date that is not after the start date.
    case invalidDateRange
    /// Indicates an attempt to start sleep while one is already active.
    case activeSleepAlreadyRunning

    /// A localized error description for UI presentation.
    public var errorDescription: String? {
        switch self {
        case .invalidDateRange:
            return "End date must be after start date."
        case .activeSleepAlreadyRunning:
            return "A sleep session is already running."
        }
    }
}
