//
//  SleepEditorViewModel.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Combine
import Foundation

/// View model for creating, editing, and deleting sleep records.
@MainActor
public final class SleepEditorViewModel: ObservableObject {
    /// Editable draft used by form fields.
    @Published public var draft: SleepEditorDraft

    /// Indicates whether existing record data is being loaded.
    @Published public private(set) var isLoading: Bool

    /// Optional error message for alert presentation.
    @Published public var errorMessage: String?

    /// True when the model has changes and save should be visible.
    public var shouldShowSave: Bool {
        hasChanges
    }

    /// True when reset should be visible for persisted models with changes.
    public var shouldShowReset: Bool {
        existingRecord != nil && hasChanges
    }

    /// True when delete should be visible for persisted models.
    public var shouldShowDelete: Bool {
        existingRecord != nil
    }

    private let recordID: UUID?
    private let sleepStore: any SleepStoreProtocol

    private var originalDraft: SleepEditorDraft
    private var existingRecord: SleepRecord?

    /// Creates a view model for either create or edit flow.
    public init(recordID: UUID?, sleepStore: any SleepStoreProtocol) {
        self.recordID = recordID
        self.sleepStore = sleepStore

        let initialDraft = SleepEditorDraft.makeDefault()
        self.draft = initialDraft
        self.originalDraft = initialDraft
        self.isLoading = recordID != nil
        self.existingRecord = nil
    }

    /// Loads the existing record when in edit mode.
    public func load() async {
        guard let recordID else {
            isLoading = false
            return
        }

        let found = await sleepStore.record(for: recordID)
        existingRecord = found

        if let found {
            let persistedDraft = SleepEditorDraft(record: found)
            draft = persistedDraft
            originalDraft = persistedDraft
        }

        isLoading = false
    }

    /// Resets the draft to original persisted or initial values.
    public func reset() {
        draft = originalDraft
    }

    /// Saves create or edit changes. Returns true when dismiss is appropriate.
    public func save() async -> Bool {
        if let existingRecord {
            var updated = existingRecord
            updated.startDate = draft.startDate
            updated.endDate = draft.endDate
            updated.note = draft.note

            do {
                try await sleepStore.updateRecord(updated)
                let persistedDraft = SleepEditorDraft(record: updated)
                originalDraft = persistedDraft
                draft = persistedDraft
                self.existingRecord = updated
                return true
            } catch {
                errorMessage = error.localizedDescription
                return false
            }
        }

        do {
            let created = try await sleepStore.createRecord(
                startDate: draft.startDate,
                endDate: draft.endDate,
                note: draft.note
            )
            let persistedDraft = SleepEditorDraft(record: created)
            originalDraft = persistedDraft
            draft = persistedDraft
            existingRecord = created
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Deletes the persisted model. Returns true when dismiss is appropriate.
    public func deleteRecord() async -> Bool {
        guard let existingRecord else {
            return false
        }

        do {
            try await sleepStore.deleteRecord(id: existingRecord.id)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private var hasChanges: Bool {
        draft != originalDraft
    }
}
