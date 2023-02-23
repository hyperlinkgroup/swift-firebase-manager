//
//  EmailPassword.swift
//  
//
//  Created by Anna Münster on 12.01.23.
//

import Foundation
import FirebaseAuth

extension AuthenticationManager {
    
    public static func signUpWithEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
        guard configuration.authProvider.contains(.emailPassword) else {
            completion(AuthenticationError.configuration)
            return
        }
        
        auth.createUser(withEmail: email, password: password) { _, error in
            if let error {
                completion(AuthenticationError.firebase(error: error))
                return
            }
            
            print("Welcome user with id \(userId ?? "")")
            self.currentProvider = .emailPassword
            completion(nil)
        }
    }
    
    public static func loginWithEmail(email: String, password: String, completion: @escaping (Error?) -> Void) {
        guard configuration.authProvider.contains(.emailPassword) else {
            completion(AuthenticationError.configuration)
            return
        }
        
        auth.signIn(withEmail: email, password: password) { _, error in
            if let error {
                completion(AuthenticationError.firebase(error: error))
                return
            }
            
            print("Welcome user with id \(userId ?? "")")
            self.currentProvider = .emailPassword
            completion(nil)
        }
    }
    
    public static func resetPassword(for email: String) {
        auth.sendPasswordReset(withEmail: email) { error in
            print("Reset mail was sent successfully to \(email)")
        }
    }
    
    private static func reauthenticateWithEmail(password: String, completion: @escaping (Error?) -> Void) {
        guard let currentUser, let email = currentUser.email else {
            completion(AuthenticationError.unauthorized)
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        currentUser.reauthenticate(with: credential) { _, error in
            if let error {
                completion(AuthenticationError.firebase(error: error))
                return
            }
            
            completion(nil)
        }
    }
    
    public static func updateMail(currentPassword: String, newMail: String, completion: @escaping (Error?) -> Void) {
        guard let currentUser else {
            completion(AuthenticationError.unauthorized)
            return
        }
        
        reauthenticateWithEmail(password: currentPassword) { error in
            if let error {
                completion(error)
                return
            }
            
            currentUser.updateEmail(to: newMail)
            completion(nil)
        }
    }
    
    public static func updatePassword(currentPassword: String, newPassword: String, completion: @escaping (Error?) -> Void) {
        guard let currentUser else {
            completion(AuthenticationError.unauthorized)
            return
        }
        
        reauthenticateWithEmail(password: currentPassword) { error in
            currentUser.updatePassword(to: newPassword) { error in
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
    
    public static func deleteAccount(currentPassword: String, completion: @escaping (Error?) -> Void) {
        guard let currentUser else {
            completion(AuthenticationError.unauthorized)
            return
        }
        
        reauthenticateWithEmail(password: currentPassword) { error in
            currentUser.delete { error in
                if let error {
                    completion(AuthenticationError.firebase(error: error))
                    return
                }
                
                self.currentProvider = nil
                
                completion(nil)
            }
        }
    }
}
