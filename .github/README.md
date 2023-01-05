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
- [X] Handling Authentication and Authorization using SignInWithApple

---

## Installation
##### Requirements
- iOS 14.0+ / macOS 10.14+
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
- [x] Support for nested collections
- [x] Snapshot Listeners
- [x] Batch writing for creating multiple documents


In the first step you need to define your collections by implementing the ReferenceProtocol. In case of nested collections, you need to pass the top-level document Id as associated value.
Example definition for two top-level collections (countries, notes), where every country-document has a cities-collection associated:
```Swift
import FirebaseFirestoreManager

enum FirestoreReference: ReferenceProtocol {
    case country, city(countryId: String), notes, users
    
    var rawValue: String {
        switch self {
        case .country: return "countries"
        case .city: return "cities"
        case .notes: return "notes"
        }
    }
    
    func parent() -> ParentReference? {
        switch self {
        case .city(let countryId):
            // path is /country/{countryId}/city
            return ParentReference(reference: FirestoreReference.country, id: countryId)
        case .country, .users: return nil
        case .notes:
            // Notes is a subdirectory of the current user (users/{userId}/notes), so in case we don't have a userId, we cannot generate the correct path
            guard let userId = UserRepository.userId else {
                throw FirestoreError.incompleteReference(reference: self)
            }
            return ParentReference(reference: FirestoreReference.users, id: userId)
        }
    }
}
```

Next you need to define all your model classes, conforming to Codable-protocol.

Example:
```Swift
public struct City: Codable {

    let name: String
    let state: String?
    let isCapital: Bool?
    let population: Int64?

    enum CodingKeys: String, CodingKey {
        case name
        case state
        case isCapital = "capital"
        case population
    }

}
```

Afterwards you can use all FirebaseFirestoreManager-classes for creating, reading, updating or deleting data.

Example:
```Swift
import FirebaseFirestoreManager

// Create new document
let country = Country(....)
FirestoreManager.createDocument(country, reference: FirestoreReference.country) { _ in }

// Read all documents from a collection
FirestoreManager.fetchCollection(FirestoreReference.country) { (result: Result<[Country], FirestoreError>) in
    switch result {
    case .success(let countries):
        // Here you can use the fetched countries!
        print(countries)
    case .failure(let error):
        print(error.localizedDescription)
    }
}

// Read specific city-document
FirestoreManager.fetchDocument(id: "LA", reference: FirestoreReference.city(countryId: "USA")) { (result: Result<City, FirestoreError>) in
    switch result {
    case .success(let city):
        print(city)
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
Target for all authentication related operations.


##### Status
- [x] Anonymous Authentication
- [x] Authentication by Apple Id
- [x] Error Handling
- [x] Link Anonymous and authenticated Accounts
- [ ] Authentication by Email and Password
- [x] Sign out and Deleting an Account
- [x] UIKit-View for handling SignInWithApple-Requests


##### Configuration
By default the `AuthenticationManager` is using Sign In With Apple and allows also anonymous authentication. If you want to disable it, you can use a custom configuration object.

You can also link a repository where you manage your users details. If you subclass the `UserRepositoryProtocol`your user's details with the user details you get during the authentication process.

```Swift
import FirebaseAuthenticationManager

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    var authenticationConfiguration = Configuration()
    authenticationConfiguration.allowAnonymousUsers = false 
    authenticationConfiguration.userRepository = MyRepository.shared
    AuthenticationManager.setup(authenticationConfiguration)

    return true
}
```


##### Authenticate by using Apple Id

The Authentication Manager controls the whole authentication flow and returns you the handled error without any further work.

###### SwiftUI:
```Swift
import FirebaseAuthenticationManager
import AuthenticationServices

struct SignInButton: View {

    var body: some View {
        SignInWithAppleButton(
            onRequest: { request in
                _ = AuthenticationManager.editRequest(request, scopes: [.email])
            }, onCompletion : { result in
                AuthenticationManager.handleAuthorizationResult(result) { error in
                    if let error {
                        // Check detailed Error Response
                    } else {
                        // Authentication was successful
                    }
                }
            }) 
    }
}
```

###### UIKit:
```Swift
import FirebaseAuthenticationManager
import AuthenticationServices

class ViewController: UIViewController {

    func authenticateBySignInWithApple() {
        let request = AuthenticationManager.editRequest(scopes: [.email])
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
}


extension ViewController: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        AuthenticationManager.handleAuthorizationResult(.success(authorization)) { error in
            if let error {
                // Check detailed Error Response
            } else {
                // Authentication was successful
            }
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        AuthenticationManager.handleAuthorizationResult(.failure(error)) { handledError in
            if let handledError {
                // Check detailed Error Response
            } else {
                // Authentication was successful
            }
        }
    }
}
```

We wrapped the above code in a custom `SignInWithAppleAuthenticationView` to simplify the delegation. To receive the final result, you can implement the `SignInWithAppleAuthenticationDelegate`:

```Swift
import FirebaseAuthenticationManager

class ViewController: UIViewController {
    // Create a reference to the custom view
    lazy var authenticationView = SignInWithAppleAuthenticationView(view: self.view, delegate: self)


    override func viewDidLoad() {
        super.viewDidLoad()

        let signupWithAppleButton = ASAuthorizationAppleIDButton()

        signupWithAppleButton.addTarget(self, action: #selector(signupWithApple), for: .touchUpInside)

        view.addSubview(signupWithAppleButton)
    }

    @objc
    func signupWithApple() {
        authenticationView?.authenticateBySignInWithApple()
    }
}

extension ViewController: SignInWithAppleAuthenticationDelegate {
    func signInWithAppleCompleted(error: Error?) {
        if error {
            // Check detailed Error Response
        } else {
            // Authentication was successful
        }
    }
}
```


##### Authenticate anonymously

Firebase gives the opportunitiy to sign up anonymously so users can use your app without any account information while staying identifiable.

```Swift
AuthenticationManager.authenticateAnonymously { error in
    if let error {
        // Check detailed Error Response
    } else {
        // Authentication was successful
    }
}
```