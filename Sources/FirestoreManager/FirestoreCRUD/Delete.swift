//
//  FirestoreManager+Delete.swift
//  
//
//  Created by Anna Münster on 26.08.21.
//

import Foundation

extension FirestoreManager {
    /**
     Delete a document in Firebase.
     
     - Parameter id: ID to be set for the document
     - Parameter reference: The collection name
     */
    public static func deleteDocument(id: String, reference: ReferenceProtocol, completion: ((FirestoreError?) -> Void)? = nil) {
        reference.reference().document(id).delete { error in
            if let error = error {
                completion?(FirestoreError.delete(error: error))
            } else {
                completion?(nil)
            }
        }
    }
}
