//
//  FirestoreReference.swift
//  
//
//  Created by Anna Münster on 03.06.22.
//

import Firebase

public protocol ReferenceProtocol {
    var rawValue: String { get }
    func parent() throws -> ParentReference?
}

extension ReferenceProtocol {
    public func reference() throws -> CollectionReference {
        if let parent = try parent() {
            return try parent.reference.reference().document(parent.id).collection(rawValue)
        } else {
            return FirestoreManager.database.collection(rawValue)
        }
    }
}

public struct ParentReference {
    public var reference: ReferenceProtocol
    public var id: String
    
    public init?(reference: ReferenceProtocol, id: String?) {
        guard let id = id else { return nil }
        self.reference = reference
        self.id = id
    }
}

