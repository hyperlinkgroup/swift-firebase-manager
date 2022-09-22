//
//  FirestoreError.swift
//  
//
//  Created by Anna Münster on 03.06.22.
//

import Foundation

public enum FirestoreError: LocalizedError {
//    case notAuthorized
    case create(error: Error)
    case decoding(error: Error)
    case delete(error: Error)
    case documentNotFound(error: Error?)
    case update(error: Error)
    
    public var errorDescription: String? {
        switch self {
        case .create(let error): return "Error creating document: \(error.localizedDescription)"
        case .decoding(let error): return "Error decoding result: \(error.localizedDescription)"
        case .delete(let error): return "Error deleting document: \(error.localizedDescription)"
        case .documentNotFound(let error): return "Error finding document: \(error?.localizedDescription ?? "")"
        case .update(let error): return "Error updating document(s): \(error.localizedDescription)"
//        case .notAuthorized: return "Error: Not authorized"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .create(let error): return String(describing: error)
        case .decoding(let error): return String(describing: error)
        case .delete(let error): return String(describing: error)
        case .update(let error): return String(describing: error)
        default: return nil
        }
    }
}
