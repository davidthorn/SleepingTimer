//
//  DashboardRoute.swift
//  SleepingTimer
//
//  Created by David Thorn on 13.02.2026.
//

import Foundation

/// Navigation routes owned by `DashboardScene`.
public enum DashboardRoute: Hashable, Sendable {
    /// Presents manual record creation.
    case create
    /// Presents editing for the given record identifier.
    case edit(UUID)
}
