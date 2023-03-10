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
    public var filters: [FirestoreFilter]?
    public var filterDict: [String: Any]?
    public var order: [String]?
    public var descending = false
    public let ref: ReferenceProtocol
    
    private let snapShotListenerReference: String

    public init(reference: ReferenceProtocol, filters: [FirestoreFilter]? = nil, filterDict: [String: Any]? = nil, order: [String]? = nil, descending: Bool = false) {
        self.ref = reference
        self.filters = filters
        self.filterDict = filterDict
        self.order = order
        self.descending = descending
        
        snapShotListenerReference = filters?.reduce(reference.rawValue) { partialResult, filter in
            partialResult + filter.key + String(describing: filter.value)
                                         } ?? reference.rawValue
    }
    
    
    open func fetchCollection(withListener: Bool) {
        FirestoreManager.fetchCollection(ref, filters: filters, filterDict: filterDict, orderBy: order, descending: descending, withListener: withListener, listenerName: snapShotListenerReference) { (result: Result<[T], FirestoreError>) in
            switch result {
            case .success(let objects):
                self.objects.send(objects)
            case .failure(let error):
                self.didReceiveError(error)
            }
        }
    }
    
    public func removeSnapshotListener() {
        FirestoreManager.removeSnapshotListener(snapShotListenerReference)
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
    
    private func getPath(id: String) -> String {
        if let path = try? ref.reference().path {
            return "/" + path + "/\(id)"
        } else {
            return "/\(id)"
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
