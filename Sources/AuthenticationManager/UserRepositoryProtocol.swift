//
//  UserRepositoryProtocol.swift
//  
//
//  Created by Anna Münster on 20.09.22.
//

import Foundation

public protocol UserRepositoryProtocol {
    /**
     This is executed automatically after a successful authorization.
     
     If you stored your users details in a remote database, this can be handy as you might need these information after launching the app.
     */
    func fetchCurrentUser()
    
    /**
     During the Process of Sign In With Apple, you receive the user's details in here (depending on your requested scope) and can store or update them in a database of your choice.
     - Attention: If a user signs in multiple times on the same device, we don't receive any values in here. So keep that in mind to prevent overwriting any already stored values in your database.
     
     - Parameters:
        - email: The email address the user entered. Need to set the scope to `[ASAuthorization.email]` on request to receive a value in here.
        - name: The full name the user entered joined to a single string. Need to set the scope to `[ASAuthorization.fullName]` on request to receive a value in here.
        - completion: After updating your database, you need to the completion to proceed with the authentication flow
        - error: If any error occured during your database transactions, you can pass it in the completion to notify that the authentication procedure included errors
     */
    func receivedUserDetails(email: String?, name: String?, completion: @escaping (_ error: Error?) -> Void)
}

extension UserRepositoryProtocol {
    public var userId: String? {
        AuthenticationManager.userId
    }
    
    
    // MARK: - Authorization
    
    /**
     Call this method if you support Sign In With Apple to check a user's authorization status on app start, or possibly before sensitive transactions, since these could be changed outside of your app.
     */
    public func checkAuthorization(completion: @escaping (Error?) -> Void) {
        AuthenticationManager.checkAuthorizationState { result in
            switch result {
            case .success:
                fetchCurrentUser()
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    /**
     Call this method if you support Sign In With Apple or Anonymous Login to check a user's authorization status on app start, or possibly before sensitive transactions, since these could be changed outside of your app.
     */
    public func checkAuthorizationWithAnonymousUser(completion: @escaping (Error?) -> Void) {
        if AuthenticationManager.userIsAuthenticated {
            self.checkAuthorization(completion: completion)
        } else {
            AuthenticationManager.authenticateAnonymously { error in
                if error != nil {
                    fetchCurrentUser()
                }
                completion(error)
            }
        }
    }
}
