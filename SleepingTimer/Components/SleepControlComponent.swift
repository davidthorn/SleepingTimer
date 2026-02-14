//
//  SleepControlComponent.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import SwiftUI

/// Reusable sleep timer controls component.
public struct SleepControlComponent<Route: Hashable>: View {
    @StateObject private var viewModel: SleepControlViewModel

    /// Route value used to navigate to manual-create flow.
    public let createRoute: Route
    /// Label shown for the manual-create navigation action.
    public let manualAddTitle: String

    /// Creates a reusable sleep control component.
    public init(
        sleepStore: SleepStoreProtocol,
        createRoute: Route,
        manualAddTitle: String = "Add Sleep Manually"
    ) {
        let vm = SleepControlViewModel(sleepStore: sleepStore)
        _viewModel = StateObject(wrappedValue: vm)
        self.createRoute = createRoute
        self.manualAddTitle = manualAddTitle
    }

    /// Sleep control interface content.
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Sleep Control", systemImage: "bed.double.fill")
                .font(.headline)

            if let activeSleepStart = viewModel.activeSleepStart {
                Label("Started: \(activeSleepStart, style: .time)", systemImage: "clock.fill")
                    .font(.subheadline)
                    .foregroundStyle(secondaryTextColor)

                activeDurationSection

                Button {
                    Task {
                        if Task.isCancelled {
                            return
                        }
                        await viewModel.endSleepNow()
                    }
                } label: {
                    Label("Awake", systemImage: "sun.max.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isActionInFlight)
            } else {
                Button {
                    Task {
                        if Task.isCancelled {
                            return
                        }
                        await viewModel.startSleepNow()
                    }
                } label: {
                    Label("Start Sleep", systemImage: "moon.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isActionInFlight)

                NavigationLink(value: createRoute) {
                    Label(manualAddTitle, systemImage: "square.and.pencil")
                        .font(.subheadline.weight(.medium))
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.45), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
        .tint(primaryAccent)
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

    private var cardBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.91, blue: 0.95),
                Color(red: 0.89, green: 0.95, blue: 0.99)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var primaryAccent: Color {
        Color(red: 0.85, green: 0.32, blue: 0.55)
    }

    private var secondaryTextColor: Color {
        Color(red: 0.40, green: 0.45, blue: 0.52)
    }

    private var activeDurationSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Sleeping For", systemImage: "moon.zzz.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(secondaryTextColor)

            Text(viewModel.activeSleepDurationText)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(primaryAccent)
                .accessibilityLabel("Current sleep duration")
                .accessibilityValue(viewModel.activeSleepDurationText)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SleepControlComponent(sleepStore: SleepStore(), createRoute: DashboardRoute.create)
    }
    .padding()
}
#endif
