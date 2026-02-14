//
//  DefaultSleepStoreStorageURLProvider.swift
//  SleepingTimer
//
//  Created by David Thorn on 14.02.2026.
//

import Foundation

/// Default Documents-directory URL provider for `SleepStore`.
public struct DefaultSleepStoreStorageURLProvider: SleepStoreStorageURLProviding, Sendable {
    /// Creates a default provider.
    public init() {}

    /// Resolves the app Documents-directory URL for the given file name.
    public func storageURL(fileName: String) throws -> URL {
        guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw CocoaError(.fileNoSuchFile)
        }

        return documents.appendingPathComponent(fileName)
    }
}
