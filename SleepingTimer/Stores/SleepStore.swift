//
//  SleepStore.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Foundation

/// Actor-based JSON persistence store for sleep records.
public actor SleepStore: SleepStoreProtocol {
    /// The file name used in the app Documents directory.
    public static let fileName = "sleep_records.json"

    private var snapshotState: SleepDataSnapshot
    private var continuations: [UUID: AsyncStream<SleepDataSnapshot>.Continuation]

    /// Creates an empty store instance.
    public init() {
        self.snapshotState = SleepDataSnapshot()
        self.continuations = [:]
    }

    /// Loads persisted records from Documents directory.
    public func loadFromDisk() async throws {
        let fileURL = try Self.storageURL()
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            try persist()
            publishCurrentState()
            return
        }

        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        snapshotState = try decoder.decode(SleepDataSnapshot.self, from: data)
        normalizeAndSortRecords()
        publishCurrentState()
    }

    /// Returns an async stream that emits state snapshots over time.
    public func snapshotStream() -> AsyncStream<SleepDataSnapshot> {
        AsyncStream { continuation in
            let id = UUID()
            continuations[id] = continuation
            continuation.yield(snapshotState)

            continuation.onTermination = { [weak self] _ in
                Task {
                    await self?.removeContinuation(id: id)
                }
            }
        }
    }

    /// Returns the current in-memory snapshot.
    public func snapshot() -> SleepDataSnapshot {
        snapshotState
    }

    /// Starts a new active sleep timer.
    public func startSleep(at date: Date) async throws {
        snapshotState.activeSleepStart = date
        try persist()
        publishCurrentState()
    }

    /// Ends the active timer and persists the resulting sleep record.
    public func endSleep(at date: Date) async throws -> SleepRecord? {
        guard let start = snapshotState.activeSleepStart else {
            return nil
        }

        guard date > start else {
            throw SleepStoreError.invalidDateRange
        }

        snapshotState.activeSleepStart = nil
        let record = SleepRecord(startDate: start, endDate: date, note: "")
        snapshotState.records.append(record)
        normalizeAndSortRecords()

        try persist()
        publishCurrentState()
        return record
    }

    /// Creates and persists a new manual sleep record.
    public func createRecord(startDate: Date, endDate: Date, note: String) async throws -> SleepRecord {
        guard endDate > startDate else {
            throw SleepStoreError.invalidDateRange
        }

        let record = SleepRecord(startDate: startDate, endDate: endDate, note: note)
        snapshotState.records.append(record)
        normalizeAndSortRecords()

        try persist()
        publishCurrentState()
        return record
    }

    /// Updates a persisted sleep record by identifier.
    public func updateRecord(_ record: SleepRecord) async throws {
        guard record.endDate > record.startDate else {
            throw SleepStoreError.invalidDateRange
        }

        guard let index = snapshotState.records.firstIndex(where: { $0.id == record.id }) else {
            return
        }

        var updated = record
        updated.updatedAt = Date()
        snapshotState.records[index] = updated
        normalizeAndSortRecords()

        try persist()
        publishCurrentState()
    }

    /// Deletes a persisted sleep record by identifier.
    public func deleteRecord(id: UUID) async throws {
        snapshotState.records.removeAll { $0.id == id }
        normalizeAndSortRecords()

        try persist()
        publishCurrentState()
    }

    /// Retrieves a record by identifier from the current state.
    public func record(for id: UUID) async -> SleepRecord? {
        snapshotState.records.first { $0.id == id }
    }

    private func normalizeAndSortRecords() {
        snapshotState.records = snapshotState.records
            .filter { $0.endDate > $0.startDate }
            .sorted { $0.startDate > $1.startDate }
    }

    private func persist() throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let fileURL = try Self.storageURL()
        let data = try encoder.encode(snapshotState)
        try data.write(to: fileURL, options: .atomic)
    }

    private func publishCurrentState() {
        for continuation in continuations.values {
            continuation.yield(snapshotState)
        }
    }

    private func removeContinuation(id: UUID) {
        continuations[id] = nil
    }

    private static func storageURL() throws -> URL {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CocoaError(.fileNoSuchFile)
        }

        return documents.appendingPathComponent(fileName)
    }
}
