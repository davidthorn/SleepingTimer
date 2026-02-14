//
//  SleepHistoryView.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import SwiftUI

/// Sleep history list view.
public struct SleepHistoryView: View {
    @StateObject private var viewModel: SleepHistoryViewModel

    /// Creates the history view and its view model.
    public init(serviceContainer: ServiceContainerProtocol) {
        let vm = SleepHistoryViewModel(sleepStore: serviceContainer.sleepStore)
        _viewModel = StateObject(wrappedValue: vm)
    }

    /// History interface content.
    public var body: some View {
        List {
            Section {
                NavigationLink(value: HistoryRoute.create) {
                    Label("Add Sleep", systemImage: "square.and.pencil")
                }
            }

            Section {
                if viewModel.records.isEmpty {
                    Text("No sleep records yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.records) { record in
                        NavigationLink(value: HistoryRoute.edit(record.id)) {
                            SleepRecordRowView(record: record)
                        }
                    }
                }
            } header: {
                Label("All Sleeps", systemImage: "list.bullet.clipboard")
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle("Sleep History")
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
        SleepHistoryView(serviceContainer: ServiceContainer(sleepStore: SleepStore()))
    }
}
#endif
