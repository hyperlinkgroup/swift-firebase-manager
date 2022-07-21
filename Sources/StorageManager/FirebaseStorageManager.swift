//
//  FirebaseStorageManager.swift
//  
//
//  Created by Anna Münster on 28.06.22.
//

import Foundation
import FirebaseStorage
import Combine

open class FirebaseStorageManager {
    
    public static func uploadFile(localFile: URL, path: String, fileName: String, fileType: FileType) -> AnyPublisher<Bool, StorageError> {
        Future { promise in
            
            let storageRef = Storage.storage().reference(withPath: "\(path)/\(fileName).\(fileType.rawValue)")
            
            let taskReference = storageRef.putFile(from: localFile, metadata: nil) { metadata, error in
                if let error = error {
                    promise(.failure(.upload(error: error)))
                }
                promise(.success(true))
            }
            
            taskReference.observe(.progress) { snapshot in
                guard let progress = snapshot.progress?.fractionCompleted
                
                else { return }
                print("File-Upload completed \(progress)%")
            }
        }.eraseToAnyPublisher()
    }
    
    public static func fetchFile(path: String, fileName: String, fileType: FileType) -> AnyPublisher<URL, StorageError> {
        Future { promise in
            do {
                let fileManager = FileManager.default
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                
                let localFile = documentDirectory.appendingPathComponent("\(fileName).\(fileType.rawValue)")
                
                let storageRef = Storage.storage().reference(withPath: "\(path)/\(fileName).\(fileType.rawValue)")
                
                storageRef.write(toFile: localFile) { url, error in
                    if let error = error {
                        promise(.failure(.download(error: error)))
                        return
                    }
                    
                    guard let url = url
                    else {
                        promise(.failure(.download(error: StorageError.urlMissing)))
                        return
                    }
                    
                    promise(.success(url.absoluteURL))
                }
            } catch {
                promise(.failure(.fileManager(error: error)))
            }
        }.eraseToAnyPublisher()
    }
    
    public static func uploadData(data: Data, path: String, fileName: String, fileType: FileType) -> AnyPublisher<URL, StorageError> {
        Future { promise in
            let storageRef = Storage.storage().reference(withPath: "\(path)/\(fileName).\(fileType.rawValue)")
            
            _ = storageRef.putData(data, metadata: nil) { metadata, error in
                
                if let error = error {
                    promise(.failure(.upload(error: error)))
                    return
                }
                
                storageRef.downloadURL { (url, urlError) in
                    
                    if let urlError = urlError {
                        promise(.failure(.upload(error: urlError)))
                        return
                    }
                    
                    guard let downloadURL = url else {
                        promise(.failure(.upload(error: StorageError.urlMissing)))
                        return
                    }
                    // File Uploaded Successfully
                    promise(.success(downloadURL))
                }
            }
        }.eraseToAnyPublisher()
    }
}
