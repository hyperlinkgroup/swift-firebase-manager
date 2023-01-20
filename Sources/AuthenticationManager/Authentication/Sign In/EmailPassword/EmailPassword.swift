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
        auth.createUser(withEmail: email, password: password) { _, error in
            if let error {
                completion(AuthenticationError.firebase(error: error))
            } else {
                print("Welcome user with id \(userId ?? "")")
                completion(nil)
            }
        }
    }
    
    public static func resetPassword(for email: String) {
        auth.sendPasswordReset(withEmail: email)
    }
    
    private static func reauthenticateWithEmail(password: String, completion: @escaping (Error?) -> Void) {
        guard let currentUser, let email = currentUser.email else {
            completion(nil)
            return
        }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        currentUser.reauthenticate(with: credential) { _, error in
            if let error {
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
    
    public static func updateMail(currentPassword: String, newMail: String, completion: @escaping (Error?) -> Void) {
        guard let currentUser else {
            completion(nil)
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
            completion(nil)
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
        reauthenticateWithEmail(password: currentPassword) { error in
            self.auth.currentUser?.delete { error in
                if let error = error {
                    completion(error)
                    return
                }
                
                completion(nil)
            }
        }
    }
}
