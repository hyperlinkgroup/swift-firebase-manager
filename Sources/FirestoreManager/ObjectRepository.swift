//
//  ObjectRepository.swift
//
//
//  Created by Anna Münster on 07.09.22.
//

import Combine
import Foundation

public protocol ObjectRepositoryProtocol: AnyObject {
    func delete() -> Future<Bool, Error>
    func rename(_ newName: String) -> Future<Bool, Error>
    func didReceiveError(_ error: Error)
}

open class ObjectRepository<T: Codable>: ObservableObject, ObjectRepositoryProtocol {
    
    @Published public var object: T
    let objectId: String
    let ref: ReferenceProtocol
    
    public init(object: T, id: String, reference: ReferenceProtocol) {
        self.objectId = id
        self.object = object
        self.ref = reference
        
        addSnapshotListener()
    }
    
    // MARK: - Functions
    
    private func addSnapshotListener() {

        FirestoreManager.fetchDocument(id: objectId, reference: ref, withListener: true) { (result: Result<T, FirestoreError>) in
            switch result {
            case .success(let object):
                self.object = object
            case .failure(let error):
                self.didReceiveError(error)
            }
        }
    }
    
    
    public func delete() -> Future<Bool, Error> {
        Future { promise in
            
            FirestoreManager.removeSnapshotListener(self.objectId)
            
            FirestoreManager.deleteDocument(id: self.objectId, reference: self.ref) { error in
                if let error = error {
                    self.didReceiveError(error)
                    promise(.failure(error))
                }
                
                promise(.success(true))
            }
        }
    }
    
    
    public func rename(_ newName: String) -> Future<Bool, Error> {
        self.update(["title": newName]) // would be good to have Enum-Values in here, but since enums cannot be inherited, I did not had an idea how to manage that
    }
    
    
    public func update(_ newValues: [String: Any]) -> Future<Bool, Error> {
        Future { promise in
            
            FirestoreManager.updateData(id: self.objectId, reference: self.ref, newValues: newValues) { result in
                
                switch result {
                case .success:
                    promise(.success(true))
                case .failure(let error):
                    self.didReceiveError(error)
                    promise(.failure(error))
                }
            }
        }
    }
    
    open func didReceiveError(_ error: Error) { }
}
