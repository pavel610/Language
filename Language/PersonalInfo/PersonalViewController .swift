//
//  AuthorizationViewController.swift
//  Language
//
//  Created by Anna on 08.07.2024.
//

import UIKit
import Firebase
import Combine

class PersonalViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userInfoStackView: UIStackView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    
    private let authManager = AuthManager.shared
    private let wordManager = WordManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    @IBAction func exitTapped(_ sender: Any) {
        WordManager.shared.clearUserDefaults()
        NotificationCenter.default.post(name: .removeAll, object: nil)
        do {
            try authManager.logout()
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let initialViewController = storyboard.instantiateInitialViewController() else {
                return
            }
            
            initialViewController.modalPresentationStyle = .fullScreen
            initialViewController.modalTransitionStyle = .coverVertical
            self.present(initialViewController, animated: true, completion: nil)
        } catch {
            print("Ошибка выхода")
        }
    }
    
    func configure() {
        guard let user = authManager.getCurrentUser() else { return }
        usernameLabel.text = user.email
        emailLabel.text = user.displayName
    }
}

