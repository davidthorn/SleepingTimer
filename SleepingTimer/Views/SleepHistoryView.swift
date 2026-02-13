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
                    Label("Add Sleep", systemImage: "plus.circle")
                }
            }

            Section("All Sleeps") {
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
            }
        }
        .navigationTitle("Sleep History")
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
        SleepHistoryView(serviceContainer: ServiceContainer(sleepStore: SleepStore()))
    }
}
#endif
