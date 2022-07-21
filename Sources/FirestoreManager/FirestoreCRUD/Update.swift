//
//  FirestoreManager+Update.swift
//  
//
//  Created by Anna Münster on 26.08.21.
//

import Foundation
import FirebaseFirestore

extension FirestoreManager {
    /**
     Update a document in Firebase.
     - Attention: The document is overwritten or newly created if it didn't exist before
     
     - Parameter object: Codable object to be uploaded
     - Parameter id: ID to be set for the document
     - Parameter reference: The collection name
     */
    public static func updateDocument<T>(_ object: T,
                                         id: String,
                                         reference: ReferenceProtocol,
                                         completion: @escaping(Result<String, FirestoreError>) -> Void) where T: Encodable {
        
        do {
            try reference.reference().document(id).setData(from: object, merge: false)
            completion(.success(id))
        } catch {
            completion(.failure(.update(error: error)))
        }
    }
    
    /**
     Update specific values of a document in Firebase.
     - Attention: values are updated or newly created if they didn't exist before
     
     - Parameter id: ID to be set for the document
     - Parameter reference: The collection name
     - Parameter newValues: Array of keys and values for all values to be updated
     */
    public static func updateData(id: String, reference: ReferenceProtocol, newValues: [String: Any], completion: @escaping(Result<String, FirestoreError>) -> Void) {
        
        reference.reference().document(id).setData(newValues, merge: true) { error in
            if let error = error {
                completion(.failure(.update(error: error)))
            } else {
                completion(.success(id))
            }
        }
    }
}
