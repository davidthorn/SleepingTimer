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
    private static let defaultDurationText = "00:00:00"

    /// Active sleep start time when a timer is running.
    @Published public private(set) var activeSleepStart: Date?

    /// Optional error message for alert presentation.
    @Published public var errorMessage: String?
    /// True while a start/end action is running.
    @Published public private(set) var isActionInFlight = false
    /// Current elapsed duration text for the active sleep session.
    @Published public private(set) var activeSleepDurationText: String

    private let sleepStore: SleepStoreProtocol
    private let durationFormatter: DateComponentsFormatter
    private var streamTask: Task<Void, Never>?
    private var clockTask: Task<Void, Never>?
    private var didStart = false

    /// Creates a sleep control view model with store dependency.
    public init(sleepStore: SleepStoreProtocol) {
        let durationFormatter = DateComponentsFormatter()
        durationFormatter.allowedUnits = [.hour, .minute, .second]
        durationFormatter.unitsStyle = .positional
        durationFormatter.zeroFormattingBehavior = [.pad]

        self.sleepStore = sleepStore
        self.durationFormatter = durationFormatter
        self.activeSleepStart = nil
        self.activeSleepDurationText = Self.defaultDurationText
    }

    deinit {
        streamTask?.cancel()
        clockTask?.cancel()
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
        guard !isActionInFlight else {
            return
        }

        isActionInFlight = true
        defer { isActionInFlight = false }

        do {
            try await sleepStore.startSleep(at: Date())
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Ends the active sleep timer using current time.
    public func endSleepNow() async {
        guard !isActionInFlight else {
            return
        }

        isActionInFlight = true
        defer { isActionInFlight = false }

        do {
            _ = try await sleepStore.endSleep(at: Date())
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
                    self.activeSleepStart = snapshot.activeSleepStart
                    self.handleActiveSleepStartChange(snapshot.activeSleepStart)
                }
            }
        }
    }

    private func handleActiveSleepStartChange(_ activeSleepStart: Date?) {
        if let activeSleepStart {
            updateElapsedDurationText(startDate: activeSleepStart)
            startClock(startDate: activeSleepStart)
        } else {
            clockTask?.cancel()
            clockTask = nil
            activeSleepDurationText = Self.defaultDurationText
        }
    }

    private func startClock(startDate: Date) {
        clockTask?.cancel()
        clockTask = Task { [weak self] in
            guard let self else {
                return
            }

            while !Task.isCancelled {
                self.updateElapsedDurationText(startDate: startDate)
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func updateElapsedDurationText(startDate: Date) {
        let elapsed = max(Date().timeIntervalSince(startDate), 0)
        activeSleepDurationText = formattedElapsedDurationText(elapsed)
    }

    private func formattedElapsedDurationText(_ elapsed: TimeInterval) -> String {
        durationFormatter.string(from: elapsed) ?? Self.defaultDurationText
    }
}
