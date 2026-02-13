//
//  SleepStoreProtocol.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Foundation

/// Actor-backed persistence interface for sleep tracking data.
public protocol SleepStoreProtocol: Actor, Sendable {
    /// Loads persisted sleep data from disk into memory.
    func loadFromDisk() async throws

    /// Emits a stream of snapshots whenever state changes.
    func snapshotStream() -> AsyncStream<SleepDataSnapshot>

    /// Returns the current in-memory snapshot.
    func snapshot() -> SleepDataSnapshot

    /// Starts an active sleep session at the provided time.
    func startSleep(at date: Date) async throws

    /// Ends the active sleep session and persists a record, if one exists.
    func endSleep(at date: Date) async throws -> SleepRecord?

    /// Persists a manually created sleep record.
    func createRecord(startDate: Date, endDate: Date, note: String) async throws -> SleepRecord

    /// Updates an existing persisted record.
    func updateRecord(_ record: SleepRecord) async throws

    /// Deletes a persisted record by identifier.
    func deleteRecord(id: UUID) async throws

    /// Returns a record by identifier when it exists.
    func record(for id: UUID) async -> SleepRecord?
}
