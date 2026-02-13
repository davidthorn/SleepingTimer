//
//  SleepControlViewModel.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Combine
import Foundation

/// View model that manages active sleep timer state and actions.
@MainActor
public final class SleepControlViewModel: ObservableObject {
    /// Active sleep start time when a timer is running.
    @Published public private(set) var activeSleepStart: Date?

    /// Optional error message for alert presentation.
    @Published public var errorMessage: String?

    private let sleepStore: SleepStoreProtocol
    private var streamTask: Task<Void, Never>?
    private var didStart = false

    /// Creates a sleep control view model with store dependency.
    public init(sleepStore: SleepStoreProtocol) {
        self.sleepStore = sleepStore
        self.activeSleepStart = nil
    }

    deinit {
        streamTask?.cancel()
    }

    /// Starts listening to timer state updates.
    public func start() async {
        guard !didStart else {
            return
        }

        didStart = true
        subscribeToSnapshotStream()
    }

    /// Starts a sleep timer using current time.
    public func startSleepNow() async {
        do {
            try await sleepStore.startSleep(at: Date())
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Ends the active sleep timer using current time.
    public func endSleepNow() async {
        do {
            _ = try await sleepStore.endSleep(at: Date())
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
                    self.activeSleepStart = snapshot.activeSleepStart
                }
            }
        }
    }
}
