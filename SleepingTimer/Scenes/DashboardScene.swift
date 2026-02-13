//
//  DashboardScene.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import SwiftUI

/// Navigation scene for dashboard flows.
public struct DashboardScene: View {
    private let serviceContainer: any ServiceContainerProtocol

    /// Creates the dashboard scene with dependencies.
    public init(serviceContainer: any ServiceContainerProtocol) {
        self.serviceContainer = serviceContainer
    }

    /// Navigation root for dashboard destinations.
    public var body: some View {
        NavigationStack {
            DashboardView(serviceContainer: serviceContainer)
                .navigationDestination(for: DashboardRoute.self) { route in
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
    DashboardScene(serviceContainer: ServiceContainer(sleepStore: SleepStore()))
}
#endif
