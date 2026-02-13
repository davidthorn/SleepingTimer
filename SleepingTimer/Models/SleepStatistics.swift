//
//  SleepStatistics.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Foundation

/// Aggregate sleep metrics for dashboard display.
public struct SleepStatistics: Hashable, Sendable {
    /// Average duration of records inside the recent window.
    public var averageDuration: TimeInterval
    /// Total number of persisted sleep records.
    public var totalSleeps: Int
    /// Duration of the most recent sleep record.
    public var mostRecentDuration: TimeInterval?

    /// Creates a statistics payload.
    public init(averageDuration: TimeInterval, totalSleeps: Int, mostRecentDuration: TimeInterval?) {
        self.averageDuration = averageDuration
        self.totalSleeps = totalSleeps
        self.mostRecentDuration = mostRecentDuration
    }

    /// Empty statistics value.
    public static let empty = SleepStatistics(averageDuration: 0, totalSleeps: 0, mostRecentDuration: nil)

    /// Calculates statistics from records using a recent-day window.
    public static func from(records: [SleepRecord], recentWindowDays: Int = 14) -> SleepStatistics {
        let sorted = records.sorted { $0.startDate > $1.startDate }
        let now = Date()
        let earliest = Calendar.current.date(byAdding: .day, value: -recentWindowDays, to: now) ?? now
        let windowRecords = sorted.filter { $0.startDate >= earliest }

        let avg: TimeInterval
        if windowRecords.isEmpty {
            avg = 0
        } else {
            let total = windowRecords.reduce(0) { $0 + max($1.duration, 0) }
            avg = total / Double(windowRecords.count)
        }

        return SleepStatistics(
            averageDuration: avg,
            totalSleeps: sorted.count,
            mostRecentDuration: sorted.first.map { max($0.duration, 0) }
        )
    }
}
