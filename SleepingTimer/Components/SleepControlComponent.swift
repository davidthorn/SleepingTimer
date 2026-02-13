//
//  SleepControlComponent.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import SwiftUI

/// Reusable sleep timer controls component.
public struct SleepControlComponent<Route: Hashable>: View {
    @StateObject private var viewModel: SleepControlViewModel

    /// Route value used to navigate to manual-create flow.
    public let createRoute: Route
    /// Label shown for the manual-create navigation action.
    public let manualAddTitle: String

    /// Creates a reusable sleep control component.
    public init(
        sleepStore: SleepStoreProtocol,
        createRoute: Route,
        manualAddTitle: String = "Add Sleep Manually"
    ) {
        let vm = SleepControlViewModel(sleepStore: sleepStore)
        _viewModel = StateObject(wrappedValue: vm)
        self.createRoute = createRoute
        self.manualAddTitle = manualAddTitle
    }

    /// Sleep control interface content.
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep Control")
                .font(.headline)

            if let activeSleepStart = viewModel.activeSleepStart {
                Text("Started: \(activeSleepStart, style: .time)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button("Awake") {
                    Task {
                        if Task.isCancelled {
                            return
                        }
                        await viewModel.endSleepNow()
                    }
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button("Start Sleep") {
                    Task {
                        if Task.isCancelled {
                            return
                        }
                        await viewModel.startSleepNow()
                    }
                }
                .buttonStyle(.borderedProminent)
            }

            NavigationLink(value: createRoute) {
                Label(manualAddTitle, systemImage: "plus.circle")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .task {
            if Task.isCancelled {
                return
            }
            await viewModel.start()
        }
        .alert("Error", isPresented: errorBinding) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SleepControlComponent(sleepStore: SleepStore(), createRoute: DashboardRoute.create)
    }
    .padding()
}
#endif
