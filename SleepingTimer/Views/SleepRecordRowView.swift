//
//  SleepRecordRowView.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import SwiftUI

/// Row view that displays one sleep record summary.
public struct SleepRecordRowView: View {
    /// Sleep record displayed by this row.
    public let record: SleepRecord

    /// Creates a row view for the provided record.
    public init(record: SleepRecord) {
        self.record = record
    }

    /// Row interface content.
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(record.startDate, style: .date)
                .font(.headline)

            HStack(spacing: 8) {
                Text(record.startDate, style: .time)
                Text("-")
                Text(record.endDate, style: .time)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)

            Text(durationText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var durationText: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: max(record.duration, 0)) ?? "0m"
    }
}

#if DEBUG
#Preview {
    SleepRecordRowView(
        record: SleepRecord(
            startDate: Date().addingTimeInterval(-8 * 60 * 60),
            endDate: Date(),
            note: ""
        )
    )
}
#endif
