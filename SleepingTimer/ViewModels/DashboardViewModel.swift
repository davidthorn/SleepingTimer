//
//  DashboardViewModel.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Combine
import Foundation

/// View model for dashboard statistics and recent records.
@MainActor
public final class DashboardViewModel: ObservableObject {
    /// Recent record list shown on dashboard.
    @Published public private(set) var recentRecords: [SleepRecord]
    /// Computed dashboard statistics.
    @Published public private(set) var statistics: SleepStatistics
    /// Indicates whether loading/subscription has started.
    @Published public private(set) var didStart = false
    /// Optional error message for alert presentation.
    @Published public var errorMessage: String?

    private let sleepStore: SleepStoreProtocol
    private var streamTask: Task<Void, Never>?

    /// Creates a dashboard view model.
    public init(sleepStore: SleepStoreProtocol) {
        self.sleepStore = sleepStore
        self.recentRecords = []
        self.statistics = .empty
    }

    deinit {
        streamTask?.cancel()
    }

    /// Starts loading data and snapshot subscription.
    public func start() async {
        guard !didStart else {
            return
        }

        didStart = true
        subscribeToSnapshotStream()

        do {
            try await sleepStore.loadFromDisk()
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
                    self.apply(snapshot)
                }
            }
        }
    }

    private func apply(_ snapshot: SleepDataSnapshot) {
        recentRecords = Array(snapshot.records.prefix(5))
        statistics = SleepStatistics.from(records: snapshot.records)
    }
}
