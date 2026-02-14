//
//  SleepEditorView.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import SwiftUI

/// Form view for creating and editing sleep records.
public struct SleepEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: SleepEditorViewModel

    private let recordID: UUID?
    @State private var showDeleteConfirmation = false

    /// Creates the editor view and its view model.
    public init(recordID: UUID?, serviceContainer: ServiceContainerProtocol) {
        self.recordID = recordID
        let vm = SleepEditorViewModel(recordID: recordID, sleepStore: serviceContainer.sleepStore)
        _viewModel = StateObject(wrappedValue: vm)
    }

    /// Editor interface content.
    public var body: some View {
        Form {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Section {
                    DatePicker("Start", selection: startDateBinding)
                    DatePicker("End", selection: endDateBinding)
                } header: {
                    Label("Sleep Window", systemImage: "moon.zzz.fill")
                }

                Section {
                    TextField("Optional note", text: noteBinding, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Label("Notes", systemImage: "note.text")
                }

                Section {
                    if viewModel.shouldShowSave {
                        Button("Save") {
                            Task {
                                if Task.isCancelled {
                                    return
                                }
                                let didSave = await viewModel.save()
                                if didSave {
                                    dismiss()
                                }
                            }
                        }
                        .disabled(!viewModel.draft.isValid)
                    }

                    if viewModel.shouldShowReset {
                        Button("Reset", role: .cancel) {
                            viewModel.reset()
                        }
                    }

                    if viewModel.shouldShowDelete {
                        Button("Delete", role: .destructive) {
                            showDeleteConfirmation = true
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(backgroundGradient.ignoresSafeArea())
        .navigationTitle(recordID == nil ? "New Sleep" : "Edit Sleep")
        .tint(primaryAccent)
        .alert("Error", isPresented: errorBinding) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Are you sure you want to delete this?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    if Task.isCancelled {
                        return
                    }
                    let didDelete = await viewModel.deleteRecord()
                    if didDelete {
                        dismiss()
                    }
                }
            }
        }
        .task {
            if Task.isCancelled {
                return
            }
            await viewModel.load()
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

    private var startDateBinding: Binding<Date> {
        Binding(
            get: { viewModel.draft.startDate },
            set: { viewModel.draft.startDate = $0 }
        )
    }

    private var endDateBinding: Binding<Date> {
        Binding(
            get: { viewModel.draft.endDate },
            set: { viewModel.draft.endDate = $0 }
        )
    }

    private var noteBinding: Binding<String> {
        Binding(
            get: { viewModel.draft.note },
            set: { viewModel.draft.note = $0 }
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
        SleepEditorView(recordID: nil, serviceContainer: ServiceContainer(sleepStore: SleepStore()))
    }
}
#endif
