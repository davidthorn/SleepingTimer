//
//  SleepEditorDraft.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Foundation

/// Editable draft model used by the sleep editor form.
public struct SleepEditorDraft: Hashable, Sendable {
    /// Draft sleep start date/time.
    public var startDate: Date
    /// Draft sleep end date/time.
    public var endDate: Date
    /// Draft note text.
    public var note: String

    /// Creates a draft from raw values.
    public init(startDate: Date, endDate: Date, note: String) {
        self.startDate = startDate
        self.endDate = endDate
        self.note = note
    }

    /// Creates a draft from an existing record.
    public init(record: SleepRecord) {
        self.startDate = record.startDate
        self.endDate = record.endDate
        self.note = record.note
    }

    /// Produces a default draft representing the last 8 hours.
    public static func makeDefault() -> SleepEditorDraft {
        let now = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -8, to: now) ?? now
        return SleepEditorDraft(startDate: start, endDate: now, note: "")
    }

    /// Indicates whether the draft date range is valid.
    public var isValid: Bool {
        endDate > startDate
    }
}
