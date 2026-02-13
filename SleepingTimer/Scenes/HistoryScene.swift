//
//  HistoryScene.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import SwiftUI

/// Navigation scene for sleep history flows.
public struct HistoryScene: View {
    private let serviceContainer: ServiceContainerProtocol

    /// Creates the history scene with dependencies.
    public init(serviceContainer: ServiceContainerProtocol) {
        self.serviceContainer = serviceContainer
    }

    /// Navigation root for history destinations.
    public var body: some View {
        NavigationStack {
            SleepHistoryView(serviceContainer: serviceContainer)
                .navigationDestination(for: HistoryRoute.self) { route in
                    switch route {
                    case .create:
                        SleepEditorView(recordID: nil, serviceContainer: serviceContainer)
                    case .edit(let recordID):
                        SleepEditorView(recordID: recordID, serviceContainer: serviceContainer)
                    }
                }
        }
    }
}

#if DEBUG
#Preview {
    HistoryScene(serviceContainer: ServiceContainer(sleepStore: SleepStore()))
}
#endif
