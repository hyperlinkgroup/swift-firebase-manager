//
//  CredentialState.swift
//  
//
//  Created by Anna Münster on 22.09.22.
//

import Foundation
import AuthenticationServices

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

extension ASAuthorizationAppleIDCredential {
    var displayName: String {
        [fullName?.givenName, fullName?.familyName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
