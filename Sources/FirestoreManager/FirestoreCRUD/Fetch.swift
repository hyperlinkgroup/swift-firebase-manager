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
     Fetch a collection from Firebase.
     
     - Parameter reference: The collection name
     - Parameter filters: Dictionary of the filter key and the value
     - Parameter orderBy: Key to order objects by
     - Parameter descending: Whether orderBy key should descend. Default is false
     - Parameter limit: Limit number of fetched items
     - Parameter withListener: Whether a listener should be added to register any changes made to the collection. Default is true
     */
    public static func fetchCollection<T>(_ reference: ReferenceProtocol,
                                          filters: [String: Any]? = nil,
                                          orderBy: [String]? = nil,
                                          descending: Bool = false,
                                          limit: Int? = nil,
                                          withListener: Bool = true,
                                          completion: @escaping (Result<[T], FirestoreError>) -> Void) where T: Decodable {
        
        do {
            var query: Query = try reference.reference()
            
            filters?.forEach { filter, filterValue in
                query = query.whereField(filter, isEqualTo: filterValue)
            }
            
            orderBy?.forEach { orderValue in
                query = query.order(by: orderValue, descending: descending)
            }
            
            if let limit {
                query = query.limit(to: limit)
            }
            
            let snapshotBlock = { (querySnapshot: QuerySnapshot?, error: Error?) in
                guard let documents = querySnapshot?.documents else {
                    completion(.failure(FirestoreError.fail(error: error, action: .read, reference: reference, id: nil)))
                    return
                }
                do {
                    let objects = try documents.map { queryDocumentSnapshot -> T in
                        try queryDocumentSnapshot.data(as: T.self)
                    }
                    
                    completion(.success(objects))
                } catch {
                    completion(.failure(FirestoreError.decoding(error: error)))
                }
            }
            
            if withListener {
                DispatchQueue.main.async {
                    let listener = query.addSnapshotListener(snapshotBlock)
                    self.snapshotListeners[reference.rawValue] =  listener
                }
            } else {
                query.getDocuments(completion: snapshotBlock)
            }
        } catch {
            completion(.failure(.incompleteReference(reference: reference)))
        }
    }
    
    
    /**
     Fetch a single document in Firebase.
     
     - Parameter id: ID of the document
     - Parameter reference: The parent's collection name
     - Parameter withListener: Whether a listener should be added to register any changes made to the collection. Default is true
     */
    public static func fetchDocument<T>(id: String,
                                        reference: ReferenceProtocol,
                                        withListener: Bool = true,
                                        completion: @escaping (Result<T, FirestoreError>) -> Void) where T: Decodable {
        do {
            let documentReference = try reference.reference().document(id)
            
            let snapshotBlock = { (document: DocumentSnapshot?, error: Error?) in
                guard let document, document.exists else {
                    completion(.failure(FirestoreError.fail(error: error, action: .read, reference: reference, id: id)))
                    return
                }
                
                do {
                    let decodedObject = try document.data(as: T.self)
                    completion(.success(decodedObject))
                } catch {
                    completion(.failure(.decoding(error: error)))
                }
            }
            
            if withListener {
                DispatchQueue.main.async {
                    let listener = documentReference.addSnapshotListener(snapshotBlock)
                    self.snapshotListeners[reference.rawValue] = listener
                }
            } else {
                documentReference.getDocument(completion: snapshotBlock)
            }
        } catch {
            completion(.failure(.incompleteReference(reference: reference)))
        }
    }
    
    /**
     Get the number of documents in a collection.
     
     - Parameter reference: The parent's collection name
     - Parameter whereTuple: Optional Key-Value-Pair for condition
     */
    public static func fetchCollectionCount(_ reference: ReferenceProtocol, whereTuple: (String, Any)? = nil, completion: @escaping (Int) -> Void) {
        do {
            var query: Query = try reference.reference()
            
            if let whereTuple {
                query = query.whereField(whereTuple.0, isEqualTo: whereTuple.1)
            }
            
            query.getDocuments { querySnapshot, _ in
                completion(querySnapshot?.documents.count ?? 0)
            }
        } catch {
            completion(0)
        }
    }
}
