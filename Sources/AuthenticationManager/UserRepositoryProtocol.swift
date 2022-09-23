//
//  UserRepositoryProtocol.swift
//  
//
//  Created by Anna Münster on 20.09.22.
//

import Foundation

public protocol UserRepositoryProtocol {
    func saveUser(name: String, email: String, completion: @escaping (Error?) -> Void)
    func fetchCurrentUser()
}

extension UserRepositoryProtocol {
    public var userId: String? {
        AuthenticationManager.userId
    }
    
    public func checkAuthorization() {
        AuthenticationManager.checkAuthorizationState { result in
            switch result {
            case .success:
                fetchCurrentUser()
            case .failure(let error):
                print(error.localizedDescription)
                AuthenticationManager.signOut { _ in }
            }
        }
    }
    
    public func checkAuthorizationWithAnonymousUser(completion: @escaping (Error?) -> Void) {
        if AuthenticationManager.userIsAuthenticated {
            AuthenticationManager.checkAuthorizationState { result in
                switch result {
                case .success:
                    fetchCurrentUser()
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
            }
        } else {
            AuthenticationManager.authenticateAnonymously(completion: completion)
        }
    }
}
