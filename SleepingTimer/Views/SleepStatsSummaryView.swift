//
//  SleepStatsSummaryView.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import SwiftUI

/// Summary card view for sleep statistics.
public struct SleepStatsSummaryView: View {
    /// Statistics payload shown by the card.
    public let statistics: SleepStatistics

    /// Creates a summary view with statistics.
    public init(statistics: SleepStatistics) {
        self.statistics = statistics
    }

    /// Summary card interface content.
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sleep")
                .font(.headline)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Average (14d)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatDuration(statistics.averageDuration))
                        .font(.title3.weight(.semibold))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(statistics.totalSleeps)")
                        .font(.title3.weight(.semibold))
                }
            }

            if let recentDuration = statistics.mostRecentDuration {
                Text("Last sleep: \(formatDuration(recentDuration))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: max(duration, 0)) ?? "0m"
    }
}

#if DEBUG
#Preview {
    SleepStatsSummaryView(
        statistics: SleepStatistics(averageDuration: 7.2 * 60 * 60, totalSleeps: 21, mostRecentDuration: 8 * 60 * 60)
    )
    .padding()
}
#endif
