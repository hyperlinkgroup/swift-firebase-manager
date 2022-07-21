//
//  AuthenticationManager.swift
//  
//
//  Created by Kevin Waltz on 22.04.22.
//

import SwiftUI

open class AuthenticationManager {
    static let providerId = "apple.com"
    static let authorizationIdKey = "appleAuthorizedUserIdKey"
    
    static var currentNonce: String?
    
    // TODO
    func createDevUser(completion: @escaping ((String, String) -> Void)) {
        // login with email<
        completion("abc@dev.de", "uid123")
    }
    
    func login() {
        #if DEBUG
        
        // set auth
        #endif
        
    }
}
