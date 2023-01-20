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

- [FirebaseFirestoreManager](#firebasefirestoremanager)
- [FirebaseStorageManager](#firebasestoragemanager)
- [FirebaseAuthenticationManager](#firebaseauthenticationmanager)

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

Next you need to define all your model classes, conforming to Codable-protocol:
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

Afterwards you can use all `FirebaseFirestoreManager`-classes for creating, reading, updating or deleting data.:
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
- [x] Authentication by Email and Password
- [x] Sign out and Deleting an Account
- [x] UIKit-View for handling SignInWithApple-Requests

##### Public Properties

```Swift
import FirebaseAuthenticationManager

AuthenticationManager.hasUser // returns true if user is authenticated
AuthenticationManager.userId // returns the id of the currently authenticated user, nil if the user is unauthenticated
AuthenticationManager.userIsAuthenticated // returns true if user is authenticated and not anonymous

AuthenticationManager.userName // returns concatenated name ("John Doe" or "John") if User provided details during Sign In with Apple or was set manually
AuthenticationManager.userName = "Jane Doe" // userName is overwritten and cannot be restored

AuthenticationManager.email // returns email if User provided details during Sign In with Apple or was set manually
AuthenticationManager.email = "john.doe@apple.com" // email is overwritten and cannot be restored
```


##### Configuration
By default the `AuthenticationManager` allows three authentication methods: Sign in with Email and Password, by using the Apple ID and anonymous login. If you want to restrict the providers, you can use a custom configuration object. With that the AuthenticationManager needs to be initialized on App Start.

You can also link a repository where you manage your users details. If you subclass the `UserRepositoryProtocol`your user's details with the user details you get during the authentication process.

If you don't need custom settings, you don't need to call the `.setup(:_)`-Function and can start using the Manager wherever you need it.


###### SwiftUI:
```Swift
import SwiftUI
import Firebase
import FirebaseAuthenticationManager

@main
struct MyApp: App {
    init() {
        FirebaseApp.configure()

        var authenticationConfiguration = Configuration()
        authenticationConfiguration.authProvider = [.signInWithApple, .anonymous, .emailPassword] 
        authenticationConfiguration.userRepository = MyRepository.shared
        AuthenticationManager.setup(authenticationConfiguration)
    }
}
```

###### UIKit:
```Swift
import UIKit
import Firebase
import FirebaseAuthenticationManager

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    FirebaseApp.configure()

    var authenticationConfiguration = Configuration()
    authenticationConfiguration.authProvider = [.signInWithApple, .anonymous, .emailPassword]
    authenticationConfiguration.userRepository = MyRepository.shared
    AuthenticationManager.setup(authenticationConfiguration)

    return true
}
```


##### Authenticate with Email and Password
```Swift
// Create Account
AuthenticationManager.signUpWithEmail(email: "john.doe@apple.com", password: "123") { error in
    if let error {
        // Check detailed Error Response
    } else {
        // Account was created and User logged in successfully
    }
}

// Login
AuthenticationManager.loginWithEmail(email: "john.doe@apple.com", password: "123") { error in
    if let error {
        // Check detailed Error Response
    } else {
        // Authentication was successful
    }
}


// Update User Information
AuthenticationManager.resetPassword(for: "john.doe@apple.com")
AuthenticationManager.updateMail(currentPassword: "123", newMail: "jane.doe@apple.com") { error in }
AuthenticationManager.updatePassword(currentPassword: "123", newPassword: "456") { error in }
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


##### Sign Out

```Swift
AuthenticationManager.signOut { error in
    if let error {
        // Check detailed Error Response
    } else {
        // Sign Out was successful
    }
}
```


##### Delete Account

You can delete a user's account in Firebase.
This can require a reauthentication before executing this method which is done automatically for users who signed in with email and password.

If your user signed in with its Apple-Account, this requires involving the UI to receive the status of authentication. We don't handle this error (yet), so we advise you to execute an additional login manually before accessing this function.

```Swift
// Account is related to Email and Password
AuthenticationManager.deleteAccount(currentPassword: "123") { error in 
    if let error {
        // Check detailed Error Response
    } else {
        // Deletion of Account was successful
        // If you stored your user's data in a database, don't forget to implement deleting it separately.
    }
}

// Account is related to Apple ID
AuthenticationManager.deleteAccount { error in
    if let error {
        // Check detailed Error Response
    } else {
        // Deletion of Account was successful
        // If you stored your user's data in a database, don't forget to implement deleting it separately.
    }
}
```


##### UserRepositoryProtocol

By subclassing the `UserRepositoryProtocol`, you get a direct access to the userId if a user is authenticated.
```Swift
class UserRepository: UserRepositoryProtocol {
    static let shared = UserRepository()
}

// Use it anywhere in your app where you need it
UserRepository.shared.userId
```

During the Authentication Process with Apple the User is asked to provide some details like its name and/or email-address. You can access these information by creating a Repository-Class conforming to the `UserRepositoryProtocol`.


```Swift
class UserRepository: UserRepositoryProtocol {

    func receivedUserDetails(email: String?, name: String?, completion: @escaping (Error?) -> Void) {
        // Depending on your requested scope you receive the user's details in here and can store or update them in a database of your choice, e.g. your UserDefaults or in the Firestore.

        // Attention: If a user signs in multiple times on the same device, we don't receive any values in here. So keep that in mind to prevent overwriting any already stored values in your database.

        if let name {
            UserDefaults.standard.set(name, forKey: "username")
        }


        // Call completion to proceed with the Authentication flow. You can pass any errors that occur during your database transactions to notify that the authentication procedure included errors
        completion(nil)
    }
}
``` 

It is recommended to check a user's authorization status on app start, or possibly before sensitive transactions, since these could be changed outside of your app.

You can simplify this Authorization-Flow by implementing the `UserRepositoryProtocol`.

If you stored your users details in a remote database, you might want to fetch it after the authorization was successful.
For this you can implement the `fetchCurrentUser`-Method, which is executed automatically on successful authorization. 

```Swift
class UserRepository: UserRepositoryProtocol {

    // Custom Function for checking Authorization -> can be called anywhere in your app where you need it
    func checkAuthState() {
        self.checkAuthorization { error in
            if let error {
                // Handle Error

                // We recommend signing out
                AuthenticationManager.signOut { _ in }
            }
        }
    }

    // Is called automatically after successful authorization
    func fetchCurrentUser() {
        // your database transactions for fetching already stored value, e.g. from Firestore

        guard let userId else { return }

        FirestoreManager.fetchDocument(id: userId, reference: FirestoreReference.users) { result in
            if let user = try? result.get() {
                print("I am \(user) and my UID is \(userId)")
            }
        }
    }
}
```