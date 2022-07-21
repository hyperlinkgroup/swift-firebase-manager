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
     
     - Parameter object: Codable object to be uploaded
     - Parameter reference: The collection name
     - Parameter id: ID to be set for the document
     */
    public static func updateDocument<T>(_ object: T,
                                         reference: ReferenceProtocol,
                                         with id: String,
                                         completion: @escaping(Result<String, FirestoreError>) -> Void) where T: Encodable {
        
        do {
            try reference.reference().document(id).setData(from: object, merge: false)
            completion(.success(id))
        } catch {
            completion(.failure(.update(error: error)))
        }
    }
    
    public static func batchWrite<T>(_ data: [T], reference: ReferenceProtocol, parentId: String? = nil, completion: @escaping(FirestoreError?) -> Void) where T: Encodable {
        let batch = database.batch()
        data.forEach { element in
            
            if let encodedElement = try? Firestore.Encoder().encode(element) {
                // automatically generate unique id
                let docRef = reference.reference(parentId: parentId).document()
                batch.setData(encodedElement, forDocument: docRef)
            }
        }
        
        batch.commit { error in
            if let error = error {
                completion(.update(error: error))
            } else {
                completion(nil)
            }
        }
    }
}
