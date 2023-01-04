//
//  FirestoreError.swift
//  
//
//  Created by Anna Münster on 03.06.22.
//

import Foundation
import FirebaseFirestore

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
        case .fail(_, let action, let reference, _):
            let actionReference = "Firestore.\(reference.rawValue.capitalized).\(action.rawValue.capitalized)"
            return actionReference + (firestoreDomain ?? "")
        case .decoding: return "Firestore.Decoding"
        }
    }
    
    var firestoreDomain: String? {
        switch self {
        case .fail(let error, _, _, _):
            guard let error = error as NSError? else { return nil }
            
            switch error.code {
            case FirestoreErrorCode.permissionDenied.rawValue: return "Unauthorized"
            case FirestoreErrorCode.notFound.rawValue: return "NotFound"
            case FirestoreErrorCode.alreadyExists.rawValue: return "AlreadyExists"
            case FirestoreErrorCode.invalidArgument.rawValue: return "InvalidArgument"
            case FirestoreErrorCode.unauthenticated.rawValue: return "Unauthenticated"
            case FirestoreErrorCode.failedPrecondition.rawValue: return "FailedPrecondition"
            default: return nil
            }
        default: return nil
        }
    }
}
