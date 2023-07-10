//
//  FirestoreManager.swift
//  
//
//  Created by Anna Münster on 26.08.21.
//

import Firebase
import FirebaseFirestoreSwift


open class FirestoreManager {
    
    public static var database: Firestore = {
        guard let emulatorPort else {
            return Firestore.firestore()
        }
        let settings = Firestore.firestore().settings
        settings.host = "localhost:\(emulatorPort)"
        settings.cacheSettings = MemoryCacheSettings()
        settings.isSSLEnabled = false
        Firestore.firestore().settings = settings
        
        return Firestore.firestore()
    }()

    private static var emulatorPort: Int?
    
    static var snapshotListeners = [String: ListenerRegistration]()
    static var queryCursors = [String: [DocumentSnapshot]]()
    
    public static func setup(emulatorPort: Int? = nil) {
        FirebaseApp.configure()
        self.emulatorPort = emulatorPort
    }
    
    public static func removeSnapshotListener(_ documentId: String) {
        snapshotListeners[documentId]?.remove()
    }
}
