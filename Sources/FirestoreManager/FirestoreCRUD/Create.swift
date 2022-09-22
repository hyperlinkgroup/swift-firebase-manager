//
//  FirestoreManager+Create.swift
//  
//
//  Created by Anna Münster on 26.08.21.
//

import Foundation

extension FirestoreManager {
    /**
     Create a document in Firebase.
     
     - Parameter object: Codable object to be uploaded
     - Parameter reference: The collection name
     - Parameter id: ID to be set for the document, if nil it is created by Firebase
     - Parameter completion: If creating was successful, the documentId is returned, otherwise the error
     */
    public static func createDocument<T: Encodable>(_ object: T,
                                                    reference: ReferenceProtocol,
                                                    with id: String? = nil,
                                                    completion: @escaping(Result<String, FirestoreError>) -> Void) {
        do {
            if let id = id {
                try reference.reference().document(id).setData(from: object)
                completion(.success(id))
            } else {
                let reference = try reference.reference().addDocument(from: object)
                completion(.success(reference.documentID))
            }
        } catch {
            completion(.failure(FirestoreError.create(error: error)))
        }
    }
}
