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
        
        guard !hasUser else {
            // user is already authenticated
            completion(nil)
            return
        }
        
        auth.signInAnonymously { _, error in
            if let error = error {
                completion(AuthenticationError.firebase(error: error))
            } else {
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
