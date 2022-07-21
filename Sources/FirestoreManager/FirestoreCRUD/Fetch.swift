//
//  FirestoreManager+Fetch.swift
//  
//
//  Created by Anna Münster on 26.08.21.
//

import Foundation
import FirebaseFirestore

extension FirestoreManager {
    /**
     Fetch and listen to a collection from Firebase.
     
     - Parameter reference: The collection name
     - Parameter userFilter: Filter all objects by the current user's id
     - Parameter filters: Dictionary of the filter key and the value
     - Parameter orderBy: Key to order objects by
     - Parameter descending: Whether orderBy key should descend
     - Parameter limit: Limit number of fetched items
     */
    public static func fetchCollection<T>(_ reference: ReferenceProtocol,
                                   userFilter: Bool = true,
                                   filters: [String: Any]? = nil,
                                   orderBy: [String]? = nil,
                                   descending: Bool = false,
                                   limit: Int? = nil,
                                   completion: @escaping (Result<[T], FirestoreError>) -> Void) where T: Decodable {
        
        
        var query: Query = reference.reference()
        
        filters?.forEach { filter, filterValue in
            query = query.whereField(filter, isEqualTo: filterValue)
        }
        
        orderBy?.forEach { orderValue in
            query = query.order(by: orderValue, descending: descending)
        }
        
        if let limit = limit {
            query = query.limit(to: limit)
        }
        
        query.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                completion(.failure(.documentNotFound(error: error)))
                return
            }
            do {
                let objects = try documents.map { queryDocumentSnapshot -> T in
                    try queryDocumentSnapshot.data(as: T.self)
                }
                
                completion(.success(objects))
            } catch {
                completion(.failure(.decoding(error: error)))
            }
        }
    }
    
   
    /**
     Fetch and listen to a single document in Firebase.
     
     - Parameter reference: The parent's collection name
     - Parameter id: ID of the document
     */
    public static func fetchDocument<T>(_ reference: ReferenceProtocol,
                                 id: String,
                                 completion: @escaping (Result<T, FirestoreError>) -> Void) where T: Decodable {
        
        let reference = reference.reference().document(id)
        
        let snapshotBlock = { (document: DocumentSnapshot?, error: Error?) in
            guard let document = document, document.exists else {
                completion(.failure(.documentNotFound(error: error)))
                return
            }
            do {
                let decodedObject = try document.data(as: T.self)
                completion(.success(decodedObject))
            } catch {
                completion(.failure(.decoding(error: error)))
            }
        }
        
        reference.addSnapshotListener(snapshotBlock)
    }
}
