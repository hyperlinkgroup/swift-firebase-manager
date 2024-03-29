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
                    return
                }
                
                completion?(nil)
            }
        } catch {
            completion?(.incompleteReference(reference: reference))
        }
    }
    
    /**
     Delete a field of an object.
     
     - Parameter id:
     */
    
    public static func deleteField(id: String, reference: ReferenceProtocol, field: String, completion: @escaping((FirestoreError?) -> Void)) {
        do {
            try reference.reference().document(id)
                .updateData([field: FieldValue.delete()]) { error in
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
