//
//  SleepHistoryViewModel.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Combine
import Foundation

/// View model for complete sleep history list.
@MainActor
public final class SleepHistoryViewModel: ObservableObject {
    /// All persisted sleep records.
    @Published public private(set) var records: [SleepRecord]
    /// Indicates whether loading/subscription has started.
    @Published public private(set) var didStart = false
    /// Optional error message for alert presentation.
    @Published public var errorMessage: String?

    private let sleepStore: SleepStoreProtocol
    private var streamTask: Task<Void, Never>?
    private var isStarting = false

    /// Creates a history view model.
    public init(sleepStore: SleepStoreProtocol) {
        self.sleepStore = sleepStore
        self.records = []
    }

    deinit {
        streamTask?.cancel()
    }

    /// Starts loading data and snapshot subscription.
    public func start() async {
        guard !didStart, !isStarting else {
            return
        }

        isStarting = true
        defer { isStarting = false }

        subscribeToSnapshotStream()

        do {
            try await sleepStore.loadFromDisk()
            didStart = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func subscribeToSnapshotStream() {
        streamTask?.cancel()
        streamTask = Task { [sleepStore] in
            let stream = await sleepStore.snapshotStream()
            for await snapshot in stream {
                if Task.isCancelled {
                    break
                }

                await MainActor.run {
                    self.records = snapshot.records
                }
            }
        }
    }
}
