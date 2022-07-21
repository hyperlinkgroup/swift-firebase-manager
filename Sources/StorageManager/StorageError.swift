//
//  StorageError.swift
//  
//
//  Created by Anna Münster on 28.06.22.
//

import Foundation

public enum StorageError: LocalizedError {
    case fileManager(error: Error)
    case download(error: Error)
    case upload(error: Error)
    case urlMissing
    
    public var errorDescription: String? {
        switch self {
        case .fileManager(let error):
            return "Error accessing File System: \(error.localizedDescription)"
        case .download(let error):
            return "Error downloading from Storage: \(error.localizedDescription)"
        case .upload(let error):
            return "Error uploading to Storage: \(error.localizedDescription)"
        case .urlMissing:
            return "Error: Did not receive Firebase-URL"
        }
    }
}
