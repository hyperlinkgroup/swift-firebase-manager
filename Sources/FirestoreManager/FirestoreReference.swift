//
//  FirestoreReference.swift
//  
//
//  Created by Anna Münster on 03.06.22.
//

import Firebase

public protocol ReferenceProtocol {
    var rawValue: String { get }
    var parent: ReferenceProtocol? { get }
}

extension ReferenceProtocol {
    func reference(parentId: String? = nil) -> CollectionReference {
        if let parent = parent, let parentId = parentId {
            return parent.reference().document(parentId).collection(rawValue)
        } else {
            return FirestoreManager.database.collection(rawValue)
        }
    }
}
