//
//  SleepingTimerApp.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import SwiftUI

/// Application entry point for the SleepingTimer iOS app.
@main
public struct SleepingTimerApp: App {
    private let serviceContainer: any ServiceContainerProtocol

    /// Creates the app with its root service container.
    public init() {
        let sleepStore = SleepStore()
        self.serviceContainer = ServiceContainer(sleepStore: sleepStore)
    }

    /// Root scene for the iOS app.
    public var body: some Scene {
        WindowGroup {
            ContentView(serviceContainer: serviceContainer)
        }
    }
}
