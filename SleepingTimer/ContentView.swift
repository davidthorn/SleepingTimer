//
//  ContentView.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import SwiftUI

/// Root content view hosting the app tab navigation.
public struct ContentView: View {
    private let serviceContainer: ServiceContainerProtocol

    @State private var loadError: String?
    @State private var hasLoaded = false

    /// Creates the root content view with dependencies.
    public init(serviceContainer: ServiceContainerProtocol) {
        self.serviceContainer = serviceContainer
    }

    /// Main tab-based app interface.
    public var body: some View {
        TabView {
            DashboardScene(serviceContainer: serviceContainer)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.xaxis")
                }

            HistoryScene(serviceContainer: serviceContainer)
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }
        }
        .task {
            if Task.isCancelled || hasLoaded {
                return
            }

            hasLoaded = true
            do {
                try await serviceContainer.sleepStore.loadFromDisk()
            } catch {
                loadError = error.localizedDescription
            }
        }
        .alert("Could Not Load Sleep Data", isPresented: loadErrorBinding) {
            Button("OK", role: .cancel) {
                loadError = nil
            }
        } message: {
            Text(loadError ?? "")
        }
    }

    private var loadErrorBinding: Binding<Bool> {
        Binding(
            get: { loadError != nil },
            set: { isPresented in
                if !isPresented {
                    loadError = nil
                }
            }
        )
    }
}

#if DEBUG
#Preview {
    ContentView(serviceContainer: ServiceContainer(sleepStore: SleepStore()))
}
#endif
