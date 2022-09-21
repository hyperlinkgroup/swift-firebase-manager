//
//  AuthorizationError.swift
//  
//
//  Created by Anna Münster on 24.08.22.
//

import Foundation
import FirebaseAuth
import AuthenticationServices

enum AuthorizationError: LocalizedError {
    case credentialState(description: String, error: Error?)
    case credential(description: String? = nil, error: Error? = nil)
    case firebase(error: Error?)
    case providerId
    case unknown
}

extension ASAuthorizationAppleIDProvider.CredentialState {
    var description: String {
        switch self {
        case .revoked: return "The user’s authorization has been revoked and they should be signed out."
        case .authorized: return "The user is authorized."
        case .notFound: return "The user hasn’t established a relationship with Sign in with Apple."
        case .transferred: return "The app has been transferred to a different team, and the user’s identifier needs to be migrated."
        @unknown default: return "Unknown CredentialState"
        }
    }
}

extension AuthenticationManager {
    static func handleError(_ error: Error, completion: @escaping((Error?) -> ())) {
//        if let e = error as? AuthErrors {
//                print(e)
//        }
        
        guard let error = error as NSError? else {
            finishedHandling(state: true)
            return
        }
        
        switch error.code {
        case AuthErrorCode.requiresRecentLogin.rawValue:
            // user wants to execute a security-sensitive action and needs to reauthenticate before
            
            // completion is called, so that caller can register notification to receive updates on reauthentication
            finishedHandling(state: false)
            
            reauthenticateUser()
            return
        case AuthErrorCode.credentialAlreadyInUse.rawValue:
            // the account corresponding to the credential already exists among your users, or is already linked to a Firebase User
            // luckily we get the correct credential in the userInfo of the error
            let credentialIdentifier = AuthErrorUserInfoUpdatedCredentialKey
            if error.userInfo.keys.contains(credentialIdentifier),
               let linkedCredential = error.userInfo[credentialIdentifier] as? AuthCredential {
                self.authenticate(credential: linkedCredential) { result in
                    switch result {
                    case .success:
                        completion(nil)
                    case .failure(let error):
                        self.handleError(error, completion: completion)
                    }
                }
            }
        default:
            // Crashlytics.crashlytics().record(error: error)
            print(error.localizedDescription)
            finishedHandling(state: false)
        }
        
        // If we have a completion, we execute it. Otherwise we use the delegate
        func finishedHandling(state: Bool) {
            completion(state ? nil : AuthorizationError.unknown)
        }
    }
}
