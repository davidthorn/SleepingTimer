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
    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    /// Creates a row view for the provided record.
    public init(record: SleepRecord) {
        self.record = record
    }

    /// Row interface content.
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label {
                Text(record.startDate, style: .date)
            } icon: {
                Image(systemName: "calendar")
            }
                .font(.headline)

            HStack(spacing: 8) {
                Image(systemName: "bed.double.fill")
                    .foregroundStyle(accentColor)
                Text(record.startDate, style: .time)
                Text("-")
                Text(record.endDate, style: .time)
            }
            .font(.subheadline)
            .foregroundStyle(secondaryTextColor)

            Label(durationText, systemImage: "timer")
                .font(.caption)
                .foregroundStyle(secondaryTextColor)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(red: 0.93, green: 0.87, blue: 0.92), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }

    private var durationText: String {
        Self.durationFormatter.string(from: max(record.duration, 0)) ?? "0m"
    }

    private var accentColor: Color {
        Color(red: 0.83, green: 0.32, blue: 0.55)
    }

    private var secondaryTextColor: Color {
        Color(red: 0.37, green: 0.42, blue: 0.50)
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
