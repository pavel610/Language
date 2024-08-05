//
//  AuthorizationViewController.swift
//  Language
//
//  Created by Anna on 08.07.2024.
//

import UIKit
import Firebase

class AuthorizationViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var registerStackView: UIStackView!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var userNameTextfield: UITextField!
    
    lazy var viewModel = AuthorizationViewModel(vc: self)

    
    var signUp: Bool = false{
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextfield.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.keyboardType = .emailAddress
        emailTextField.returnKeyType = .next
        signUp = false
    }
    
    
    @IBAction func loginTapped(_ sender: Any) {
        viewModel.sendRequestToFireBase(signUp: signUp, name: userNameTextfield.text, email: emailTextField.text, password: passwordTextField.text)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        signUp.toggle()
    }
    
    func goToMain() {
        performSegue(withIdentifier: "toMain", sender: nil)
    }
    
    func showFailAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Неправильный логин или пароль", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OК", style: .default))
        present(alert, animated: true)
    }
    func showFailRegisterAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Неверные данные для регистрации", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OК", style: .default))
        present(alert, animated: true)
    }

    func showSuccessAlert() {
        let alert = UIAlertController(title: "Авторизация прошла успешно", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OК", style: .default))
        present(alert, animated: true)
    }

    func showEmptyAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Заполните все поля", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OК", style: .default))
        present(alert, animated: true)
    }
}

extension AuthorizationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case userNameTextfield:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        viewModel.sendRequestToFireBase(signUp: signUp, name: userNameTextfield.text ?? "", email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
        return true
    }
}
