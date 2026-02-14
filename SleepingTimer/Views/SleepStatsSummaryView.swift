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
    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    /// Creates a summary view with statistics.
    public init(statistics: SleepStatistics) {
        self.statistics = statistics
    }

    /// Summary card interface content.
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Recent Sleep", systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(.primary)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Average (14d)", systemImage: "moon.stars.fill")
                        .font(.caption)
                        .foregroundStyle(secondaryTextColor)
                    Text(formatDuration(statistics.averageDuration))
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(primaryAccent)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Label("Total", systemImage: "list.bullet.clipboard")
                        .font(.caption)
                        .foregroundStyle(secondaryTextColor)
                    Text("\(statistics.totalSleeps)")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(primaryAccent)
                }
            }

            if let recentDuration = statistics.mostRecentDuration {
                Label("Last sleep: \(formatDuration(recentDuration))", systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundStyle(secondaryTextColor)
            }
        }
        .padding()
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        Self.durationFormatter.string(from: max(duration, 0)) ?? "0m"
    }

    private var cardBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.93, blue: 0.96),
                Color(red: 0.90, green: 0.95, blue: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var primaryAccent: Color {
        Color(red: 0.84, green: 0.34, blue: 0.55)
    }

    private var secondaryTextColor: Color {
        Color(red: 0.38, green: 0.43, blue: 0.51)
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
