//
//  SleepStoreStorageURLProviding.swift
//  SleepingTimer
//
//  Created by David Thorn on 14.02.2026.
//

import Foundation

/// Provides a storage file URL for `SleepStore` persistence.
public protocol SleepStoreStorageURLProviding: Sendable {
    /// Returns a writable URL for the supplied file name.
    func storageURL(fileName: String) throws -> URL
}
