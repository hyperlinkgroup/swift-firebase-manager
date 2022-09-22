//
//  ErrorHandling.swift
//  
//
//  Created by Anna Münster on 22.09.22.
//

import Foundation
import FirebaseAuth

extension AuthenticationManager {
    static func handleError(_ error: Error, completion: @escaping((Error?) -> ())) {
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
