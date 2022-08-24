# FirebaseManager Package

This repository contains all utility functions that simplify transactions with Firebase products like Cloud Firestore, Cloud Storage or Authentication, wrapped in a Swift Package.
It is made by **[SPACE SQUAD](https://www.spacesquad.de)**! We make great software with ♥️ in Berlin.
<img src="assets/README-spacesquad_logo_full.png" width="120">

---

## Content
- [Features](#features)
- [Installation](#installation)
- [How to Use](#how-to-use)


## Features
- [x] CRUD-Transactions for collections and documents stored in Firebase Cloud Firestore 
- [x] CR-Transactions for documents stored in Firebase Cloud Storage 
- [ ] Handling Authentication and Authorization using SignInWithApple and Password

---

## Installation
##### Requirements
- iOS 14.0+ / macOS 10.15
- Xcode 13+
- Swift 5+

##### Swift Package Manager
In Xcode, go to `File > Add Packages` and add `https://github.com/space-squad/swift-firebase-manager`. Add the package to all your targets.


## How to Use

The package is separated into three targets and you need to import the one that fits your needs:

### FirebaseFirestoreManager
Target for all transactions with the Firebase Cloud Firestore.


##### Status
- [x] CRUD-Transactions for collections and documents
- [x] Error Handling
- [ ] Support for nested collections
- [ ] Snapshot Listeners


In the first step you need to define your collections by implementing the ReferenceProtocol.

Example definition for two top-level collections (countries, notes), where every country-document has a cities-collection associated:
```Swift
import FirebaseFirestoreManager

enum FirestoreReference: String, ReferenceProtocol {
    case country = "countries", city = "cities", notes
}
```
Next you need to define all your model classes, conforming to Codable-protocol.

Example:
```Swift
public struct City: Codable {

    let name: String
    let state: String?
    let country: String?
    let isCapital: Bool?
    let population: Int64?

    enum CodingKeys: String, CodingKey {
        case name
        case state
        case country
        case isCapital = "capital"
        case population
    }

}
```

Afterwards you can use all FirebaseFirestoreManager-classes for creating, reading, updating or deleting data.

Example:
```Swift
// Create new document
let country = Country(....)
FirestoreManager.createDocument(country, reference: FirestoreReference.country) { _ in }

// Read all documents from a collection
FirestoreManager.fetchCollection(FirestoreReference.country) { (result: Result<[Country], FirestoreError>) in
    switch result {
    case .success(let countries):
        print(countries)
    case .failure(let error):
        print(error.localizedDescription)
    }
}

// Update document
country.name = "USA"
FirestoreManager.updateDocument(country, reference: FirestoreReference.country, with: country.id) { _ in }

// Delete document
FirestoreManager.deleteDocument(reference: FirestoreReference.country, with: country.id)
```

### FirebaseStorageManager
Target for all transactions with the Firebase Cloud Storage, using the Combine-framework.

##### Status
- [x] Create files
- [x] Read files
- [ ] Delete files
- [x] Error Handling
- [ ] Hierarchical Organization
- [ ] Multiple Buckets
- [ ] Support more file types

Example:
```Swift
// Create new file in bucket in folder "directory"

let data = Data(base64Encoded: someString)!        
FirebaseStorageManager.uploadData(data: data, path: "directory", fileName: "fileName", fileType: .csv)
    .sink { _ in }
        receiveValue: { url in
            print(url.absoluteURL)
        }


// Read File from bucket
FirebaseStorageManager.fetchFile(path: "directory", fileName: "fileName", fileType: .csv)
    .tryMap { url in
        try String(contentsOf: url)
    }
    .replaceError(with: "Error")
    .sink { print($0) }
```



### FirebaseAuthenticationManager
To be completed.
