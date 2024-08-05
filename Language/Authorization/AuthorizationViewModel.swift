//
//  AuthorizationViewModel.swift
//  Language
//
//  Created by Павел Калинин on 03.08.2024.
//

import Foundation
import UIKit
import FirebaseAuth

class AuthorizationViewModel {
    private let authManager = AuthManager.shared
    var vc: AuthorizationViewController
    
    init(vc: AuthorizationViewController) {
        self.vc = vc
    }
    
    func sendRequestToFireBase(signUp: Bool, name: String?, email: String?, password: String?) {
        guard let name = name, let email = email, let password = password else { return }
        
        if signUp {
            guard !name.isEmpty && !email.isEmpty && !password.isEmpty else {
                vc.showEmptyAlert()
                return
            }
            authManager.register(email: email, password: password, displayName: name) { [weak self] result  in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    AuthorizationViewController().goToMain()
                case .failure(let error):
                    print("Failed to register: \(error.localizedDescription)")
                    vc.showFailRegisterAlert()
                }
            }
        } else {
            guard !email.isEmpty && !password.isEmpty else {
                vc.showEmptyAlert()
                return
            }
            authManager.signIn(email: email, password: password) { [weak self] result in
                switch result {
                case .success(_):
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    self?.vc.goToMain()
                case .failure(let error):
                    print("Failed to signIn: \(error.localizedDescription)")
                    self?.vc.showFailAlert()
                }
            }
        }
    }
}



