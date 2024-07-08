//
//  AuthorizationViewController.swift
//  Language
//
//  Created by Anna on 08.07.2024.
//

import UIKit
import Firebase

class AuthorizationViewController: UIViewController {
    var signUp: Bool = true {
        willSet {
            if newValue {
                titleLabel.text = "Регистрация"
                userNameTextfield.isHidden = false
                changeButton.setTitle("Уже есть аккаунт? Войти", for: .normal)
                loginButton.setTitle("Зарегистрироваться", for: .normal)
            } else {
                titleLabel.text = "Вход"
                userNameTextfield.isHidden = true
                changeButton.setTitle("У вас нет аккаунта? Зарегистрироваться", for: .normal)
                loginButton.setTitle("Войти", for: .normal)
            }
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userInfoStackView: UIStackView!
    @IBOutlet weak var registerStackView: UIStackView!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextfield: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextfield.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        Auth.auth().addStateDidChangeListener { [weak self]  auth, user in
            guard let self = self else { return }
            if let user = user {
                self.registerStackView.isHidden = true
                self.userInfoStackView.isHidden = false
                self.changeButton.isHidden = true
                self.loginButton.isHidden = true
                self.titleLabel.text = "Профиль"
                self.usernameLabel.text = "username: \(user.displayName ?? "Error name")"
                self.emailLabel.text = "Email: \(user.email ?? "Error email")"
            } else {
                self.registerStackView.isHidden = false
                self.userInfoStackView.isHidden = true
                self.changeButton.isHidden = false
                self.loginButton.isHidden = false
                self.signUp = false
            }
        }
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        sendRequestToFireBase()
    }
    @IBAction func buttonTapped(_ sender: Any) {
        signUp.toggle()
    }
    
    @IBAction func exitTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.registerStackView.isHidden = false
            self.userInfoStackView.isHidden = true
        } catch {
            print("Ошибка выхода")
        }
    }
}

extension AuthorizationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendRequestToFireBase()
        return true
    }
    
    private func sendRequestToFireBase() {
        guard let name = userNameTextfield.text else { return }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        if signUp {
            if name.isEmpty || email.isEmpty || password.isEmpty {
                showEmptyAlert()
            } else {
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error  in
                    guard let self = self  else { return }
                    if let error = error {
                        print(error)
                        showFailRegisterAlert()
                        return
                    }
                    if let result = result {
                        let changedReuest = result.user.createProfileChangeRequest()
                        changedReuest.displayName = name
                        self.usernameLabel.text = "username: \(name)"
                        changedReuest.commitChanges()
                    }
                }
            }
        } else {
            if email.isEmpty || password.isEmpty {
                showEmptyAlert()
            } else {
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                    guard let self = self else { return }
                    if let error = error {
                        print(error)
                        
                        return
                    }
                    if let result = result {
                        self.usernameLabel.text = "username: \(result.user.displayName ?? "Error name")"
                        self.showSuccessAlert()
                        
                    }
                }
            }
        }
        
    }
    
    private func showFailAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Заполните все поля", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OК", style: .default))
        present(alert, animated: true)
    }
    private func showFailRegisterAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Неверные данные для регистрации", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OК", style: .default))
        present(alert, animated: true)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Авторизация прошла успешно", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OК", style: .default))
        present(alert, animated: true)
    }
    
    private func showEmptyAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Заполните все поля", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OК", style: .default))
        present(alert, animated: true)
    }
}
