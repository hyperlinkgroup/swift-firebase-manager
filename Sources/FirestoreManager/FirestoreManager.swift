//
//  FirestoreManager.swift
//  
//
//  Created by Anna Münster on 26.08.21.
//

import Firebase
import FirebaseFirestoreSwift


open class FirestoreManager {
    static let database = Firestore.firestore()
    
    static var snapshotListeners = [String: ListenerRegistration]()
    
    public static func removeSnapshotListener(_ documentId: String) {
        snapshotListeners[documentId]?.remove()
    }
}
