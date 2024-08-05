//
//  AuthManager.swift
//  Language
//
//  Created by Павел Калинин on 09.07.2024.
//

import UIKit
import Firebase

class AuthManager {
    static let shared = AuthManager()
    private let auth = Auth.auth()
    private init() {}
    
    
    func register(email: String, password: String, displayName: String, completion: @escaping (Result<User, Error>) -> Void){
        auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = authResult?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(user))
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let user = authResult?.user {
                completion(.success(user))
            }
        }
    }
    
    func logout() throws{
        try auth.signOut()
    }
    
    func getCurrentUser() -> User? {
        return auth.currentUser
    }
    
    func addAuthStateDidChangeListener(listener: @escaping (User?) -> Void) {
        auth.addStateDidChangeListener { _, user in
            listener(user)
        }
    }
    
}

