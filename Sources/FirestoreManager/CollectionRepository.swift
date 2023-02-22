//
//  CollectionRepository.swift
//  
//
//  Created by Anna Münster on 08.01.23.
//

import Combine
import Foundation

open class CollectionRepository<T: Codable>: ObservableObject {
    
    // MARK: - Variables
    
    public var objects = CurrentValueSubject<[T], Never>([])
    public var filters: [String: Any]?
    public var order: [String]?
    public let ref: ReferenceProtocol
    
    public init(reference: ReferenceProtocol, filters: [String: Any]? = nil, order: [String]? = nil) {
        self.ref = reference
        self.filters = filters
        self.order = order
    }
    
    
    open func fetchCollection(withListener: Bool) {
        FirestoreManager.fetchCollection(ref, filters: filters, orderBy: order, withListener: withListener) { (result: Result<[T], FirestoreError>) in
            switch result {
            case .success(let objects):
                self.objects.send(objects)
            case .failure(let error):
                self.didReceiveError(error)
            }
        }
    }
    
    open func create(_ object: T) {
        FirestoreManager.createDocument(object, reference: ref) { result in
            switch result {
            case .success(let id):
                print("Created object \(self.getPath(id: id))!")
            case .failure(let error):
                self.didReceiveError(error)
            }
        }
    }
    
    open func update(_ object: T, id: String, merge: Bool = false) {
        FirestoreManager.updateDocument(object, id: id, reference: ref, merge: merge) { result in
            switch result {
            case .success:
                print("Object updated \(self.getPath(id: id))!")
            case .failure(let error):
                self.didReceiveError(error)
            }
        }
    }
    
    open func delete(id: String) {
        FirestoreManager.deleteDocument(id: id, reference: ref) { error in
            if let error {
                self.didReceiveError(error)
            } else {
                print("Object deleted \(self.getPath(id: id))!")
            }
        }
    }
    
    open func didReceiveError(_ error: Error) { }
}


extension CollectionRepository {
    private func getPath(id: String) -> String {
        if let path = try? ref.reference().path {
            return "/" + path + "/\(id)"
        } else {
            return "/\(id)"
        }
    }
}
