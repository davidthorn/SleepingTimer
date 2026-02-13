//
//  DashboardView.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import SwiftUI

/// Dashboard content view with stats, controls, and recent records.
public struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    private let sleepStore: any SleepStoreProtocol

    /// Creates the dashboard view and its view model.
    public init(serviceContainer: any ServiceContainerProtocol) {
        self.sleepStore = serviceContainer.sleepStore
        let vm = DashboardViewModel(sleepStore: serviceContainer.sleepStore)
        _viewModel = StateObject(wrappedValue: vm)
    }

    /// Dashboard interface content.
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SleepStatsSummaryView(statistics: viewModel.statistics)

                SleepControlComponent(sleepStore: sleepStore, createRoute: DashboardRoute.create)

                recentSleepsSection
            }
            .padding()
        }
        .navigationTitle("Dashboard")
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

    private var recentSleepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sleeps")
                .font(.headline)

            if viewModel.recentRecords.isEmpty {
                Text("No sleep records yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.recentRecords) { record in
                    NavigationLink(value: DashboardRoute.edit(record.id)) {
                        SleepRecordRowView(record: record)
                    }
                    .buttonStyle(.plain)
                }
            }
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
        DashboardView(serviceContainer: ServiceContainer(sleepStore: SleepStore()))
    }
}
#endif
