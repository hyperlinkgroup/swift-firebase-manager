//
//  ErrorHandling.swift
//  
//
//  Created by Anna Münster on 22.09.22.
//

import Foundation
import FirebaseAuth

extension AuthenticationManager {
    static func handleError(_ rawError: Error, completion: @escaping((Error?) -> ())) {
        guard let error = rawError as NSError? else {
            finishedHandling()
            return
        }
        
        switch error.code {
        case AuthErrorCode.requiresRecentLogin.rawValue:
            // user wants to execute a security-sensitive action and needs to reauthenticate before
            
            // completion is called, so that caller can register notification to receive updates on reauthentication
            finishedHandling()
            return
        case AuthErrorCode.credentialAlreadyInUse.rawValue:
            // the account corresponding to the credential already exists among your users, or is already linked to a Firebase User
            // luckily we get the correct credential in the userInfo of the error
            let credentialIdentifier = AuthErrorUserInfoUpdatedCredentialKey
            if error.userInfo.keys.contains(credentialIdentifier),
               let linkedCredential = error.userInfo[credentialIdentifier] as? AuthCredential {
                auth.signIn(with: linkedCredential) { result, error in
                    if let error {
                        self.handleError(error, completion: completion)
                        return
                    }
                    
                    self.currentProvider = .signInWithApple
                    completion(nil)
                }
            }
        default:
            print(error.localizedDescription)
            finishedHandling()
        }
        
        // If we have a completion, we execute it. Otherwise we use the delegate
        func finishedHandling() {
            completion(AuthenticationError.firebase(error: rawError))
        }
    }
}
