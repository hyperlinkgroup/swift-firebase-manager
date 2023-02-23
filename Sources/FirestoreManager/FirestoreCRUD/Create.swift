//
//  FirestoreManager+Create.swift
//  
//
//  Created by Anna Münster on 26.08.21.
//

import Foundation
import FirebaseFirestore

extension FirestoreManager {
    /**
     Create a document in Firebase.
     - Attention: If the document did exist before, it is overwritten
     
     - Parameter object: Codable object to be uploaded
     - Parameter reference: The collection name
     - Parameter id: ID to be set for the document, if nil it is created by Firebase
     - Parameter completion: If creating was successful, the documentId is returned, otherwise the error
     */
    public static func createDocument<T: Encodable>(_ object: T,
                                                    id: String? = nil,
                                                    reference: ReferenceProtocol,
                                                    completion: @escaping(Result<String, FirestoreError>) -> Void) {
        do {
            if let id {
                try reference.reference().document(id).setData(from: object)
                completion(.success(id))
            } else {
                let reference = try reference.reference().addDocument(from: object)
                completion(.success(reference.documentID))
            }
        } catch {
            completion(.failure(FirestoreError.fail(error: error, action: .create, reference: reference, id: id)))
        }
    }
    
    /**
     Creating multiple objects in the same collection in Firebase.
     
     - Parameter date: Codable objects to be uploaded
     - Parameter reference: The collection name
     
     */
    public static func batchWrite<T>(_ data: [T], reference: ReferenceProtocol, completion: @escaping(FirestoreError?) -> Void) where T: Encodable {
        let batch = database.batch()
        data.forEach { element in
            
            do {
                let encodedElement = try Firestore.Encoder().encode(element)
                // automatically generate unique id
                let docRef = try reference.reference().document()
                batch.setData(encodedElement, forDocument: docRef)
            } catch {
                completion(.decoding(error: error))
            }
        }
        
        batch.commit { error in
            if let error {
                completion(.fail(error: error, action: .batchCreate, reference: reference, id: nil))
                return
            }
            
            completion(nil)
        }
    }
}
