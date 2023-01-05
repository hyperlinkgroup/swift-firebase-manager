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
            if let error {
                completion(AuthenticationError.firebase(error: error))
            } else {
                print("Created account for anonymous user with id \(userId ?? "")")
                completion(nil)
            }
        }
    }
}
