//
//  FirestoreError.swift
//  
//
//  Created by Anna Münster on 03.06.22.
//

import Foundation

public enum FirestoreError: LocalizedError {
    case create(error: Error)
    case decoding(error: Error)
    case delete(error: Error)
    case documentNotFound
    case fetch(error: Error)
    case update(error: Error)
    case unknown(error: Error?)
    
    public var errorDescription: String? {
        switch self {
        case .create(let error): return "Error creating document: \(error.localizedDescription)"
        case .decoding(let error): return "Error decoding result: \(error.localizedDescription)"
        case .delete(let error): return "Error deleting document: \(error.localizedDescription)"
        case .documentNotFound: return "Error finding document"
        case .fetch(let error): return "Error fetch document(s): \(error.localizedDescription)"
        case .update(let error): return "Error updating document(s): \(error.localizedDescription)"
        case .unknown(let error): return "Unknown Error \(error?.localizedDescription ?? "")"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .create(let error): return String(describing: error)
        case .decoding(let error): return String(describing: error)
        case .delete(let error): return String(describing: error)
        case .fetch(let error): return String(describing: error)
        case .update(let error): return String(describing: error)
        default: return nil
        }
    }
}
