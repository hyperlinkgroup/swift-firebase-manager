//
//  AuthenticationError.swift
//  
//
//  Created by Anna Münster on 24.08.22.
//

import Foundation

enum AuthenticationError: LocalizedError {
    case configuration
    case firebase(error: Error?)
    case unauthorized
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .configuration:
            return "Authentication Method is not allowed according to Configuration Settings"
        case .firebase(let error):
            return "Authentication failed due to Firebase Error: \(error?.localizedDescription ?? "Unknown")"
        case .unauthorized:
            return "User is not authenticated and cannot perform this action!"
        case .unknown:
            return "An unknown Error Occured"
        }
    }
}


enum AuthorizationError: LocalizedError {
    case credentialState(description: String, error: Error?)
    case credential(description: String? = nil, error: Error? = nil)
    case providerId
    
    
    var errorDescription: String? {
        switch self {
        case .credentialState(let description, let error):
            return [error?.localizedDescription, description]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
        case .credential(let description, let error):
            return [error?.localizedDescription, description]
                .compactMap { $0 }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
        case .providerId:
            return "Method could not be executed. ProviderId does not match."
        }
    }
}
