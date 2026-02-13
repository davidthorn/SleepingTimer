//
//  SleepRecord.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Foundation

/// A persisted sleep tracking record.
public struct SleepRecord: Codable, Identifiable, Hashable, Sendable {
    /// Unique record identifier.
    public let id: UUID
    /// Sleep start date/time.
    public var startDate: Date
    /// Sleep end date/time.
    public var endDate: Date
    /// Optional user note.
    public var note: String
    /// Record creation timestamp.
    public let createdAt: Date
    /// Record last update timestamp.
    public var updatedAt: Date

    /// Creates a sleep record instance.
    public init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        note: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Computed sleep duration in seconds.
    public var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}
