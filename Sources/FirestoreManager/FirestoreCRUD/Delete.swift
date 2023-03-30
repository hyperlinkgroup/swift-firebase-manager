//
//  FirestoreManager+Delete.swift
//  
//
//  Created by Anna Münster on 26.08.21.
//

import Foundation
import FirebaseFirestore

extension FirestoreManager {
    /**
     Delete a document in Firebase.
     
     - Parameter id: ID to be set for the document
     - Parameter reference: The collection name
     */
    public static func deleteDocument(id: String, reference: ReferenceProtocol, completion: ((FirestoreError?) -> Void)? = nil) {
        do {
            try reference.reference().document(id).delete { error in
                if let error {
                    completion?(.fail(error: error, action: .delete, reference: reference, id: id))
                } else {
                    completion?(nil)
                }
            }
        } catch {
            completion?(.incompleteReference(reference: reference))
        }
    }
    
    /**
     Delete fields of an object.
     Because nil-values cannot be set during an update, these fields need to be deleted separately
     
     - Parameter id:Document ID
     - Parameter reference: The collection name
     - Parameter fields: Array of field names
     */
    
    public static func deleteFields(id: String, reference: ReferenceProtocol, fields: [String], completion: @escaping((FirestoreError?) -> Void)) {
        
        let data = fields.reduce(into: [String: Any]()) {
            $0[$1] = FieldValue.delete()
        }
        
        do {
            try reference.reference().document(id)
                .updateData(data) { error in
                    var firestoreError: FirestoreError?
                    if let error {
                        firestoreError = .fail(error: error, action: .update, reference: reference, id: id)
                    }
                    completion(firestoreError)
                }
        } catch {
            completion(.incompleteReference(reference: reference))
        }
    }
}
