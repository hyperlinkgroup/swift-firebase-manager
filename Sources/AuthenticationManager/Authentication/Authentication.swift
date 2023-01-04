//
//  Authentication.swift
//  
//
//  Created by Anna Münster on 22.09.22.
//

import Foundation

extension AuthenticationManager {
    public static func authenticateAnonymously(completion: @escaping(Error?) -> Void) {
        guard configuration.allowAnonymousUsers else {
            completion(AuthenticationError.configuration)
            return
        }
        
        if let userId {
            // user is already authenticated
            print("Welcome back anonymous user with id \(userId)")
            completion(nil)
            return
        }
        
        auth.signInAnonymously { _, error in
            if let error = error {
                completion(AuthenticationError.firebase(error: error))
            } else {
                print("Created account for anonymous user with id \(userId ?? "")")
                completion(nil)
            }
        }
    }
    
    /**
     Security-sensitive actions (deleting account for now, later may be password change or mail-adress-change) require that the user has recently signed in and we catch at this point the "requiresRecentLogin"-Error.
     When a re-authentication is needed, we need to ask the user again for the credentials.
     */
    public static func reauthenticateUser() {
        #if canImport(UIKit)
        self.authView = AuthenticationView(delegate: nil)
        self.authView?.authenticateBySignInWithApple()
        #else
        // TODO: SwiftUI
        #endif
    }
}
