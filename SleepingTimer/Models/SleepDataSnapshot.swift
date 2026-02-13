//
//  SleepDataSnapshot.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Foundation

/// Full persisted state snapshot for sleep tracking.
public struct SleepDataSnapshot: Codable, Hashable, Sendable {
    /// Persisted sleep records.
    public var records: [SleepRecord]
    /// Active running sleep start time, if present.
    public var activeSleepStart: Date?

    /// Creates a state snapshot.
    public init(records: [SleepRecord] = [], activeSleepStart: Date? = nil) {
        self.records = records
        self.activeSleepStart = activeSleepStart
    }
}
