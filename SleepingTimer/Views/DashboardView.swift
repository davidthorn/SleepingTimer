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
    private let sleepStore: SleepStoreProtocol

    /// Creates the dashboard view and its view model.
    public init(serviceContainer: ServiceContainerProtocol) {
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
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(backgroundGradient.ignoresSafeArea())
        .scrollContentBackground(.hidden)
        .navigationTitle("Dashboard")
        .tint(primaryAccent)
        .task {
            if Task.isCancelled {
                return
            }
            await viewModel.start()
        }
        .alert("Error", isPresented: errorBinding) {
            Button("Retry") {
                Task {
                    if Task.isCancelled {
                        return
                    }
                    await viewModel.start()
                }
            }
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var recentSleepsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recent Sleeps", systemImage: "moon.zzz.fill")
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.82), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
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

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.99, green: 0.95, blue: 0.97),
                Color(red: 0.92, green: 0.96, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var primaryAccent: Color {
        Color(red: 0.84, green: 0.34, blue: 0.55)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        DashboardView(serviceContainer: ServiceContainer(sleepStore: SleepStore()))
    }
}
#endif
