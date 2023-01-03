//
//  FirestoreError.swift
//  
//
//  Created by Anna Münster on 03.06.22.
//

import Foundation

public enum FirestoreAction: String {
    case create, batchCreate, read, update, delete
}

public enum FirestoreError: LocalizedError, CustomNSError {
    case fail(error: Error?, action: FirestoreAction, reference: ReferenceProtocol, id: String?)
    case decoding(error: Error)
    
    public var errorDescription: String? {
        switch self {
        case .fail(_, let action, let reference, let id): return "Firestore Error on \(action.rawValue) from reference /\(reference.rawValue)/ (Parent)Id: \(id ?? "unknown")"
        case .decoding: return "Decoding Error"
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .fail(let error, _, _, let id): return error?.localizedDescription ?? "Document \(id ?? "") not found"
        case .decoding(let error): return error.localizedDescription
        }
    }
    
    public var _domain: String {
        switch self {
        case .fail(_, let action, let reference, _): return "Firestore.\(reference.rawValue.capitalized).\(action.rawValue.capitalized)"
        case .decoding: return "Firestore.Decoding"
        }
    }
}
