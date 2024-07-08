//
//  NewWordsViewController.swift
//  Language
//
//  Created by Павел on 07.07.2024.
//

import UIKit

protocol NewWordDelegate: AnyObject {
    func didAddNewWord(_ word: Word)
}

class NewWordsViewController: UIViewController {

    @IBOutlet weak var wordTextField: UITextField!
    @IBOutlet weak var translateLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    private let yandexDictManager = YandexDictManager()
    var typingTimer: Timer?
    
    weak var delegate: NewWordDelegate?

    @IBAction func DoneButtonTapped(_ sender: Any) {
        guard let newSpelling = wordTextField.text,
              let newTranslation = translateLabel.text,
              !newSpelling.isEmpty, !newTranslation.isEmpty else { return }

        let newWord = Word(spelling: newSpelling, translation: newTranslation)
        delegate?.didAddNewWord(newWord)
        translateLabel.text = ""
        wordTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        wordTextField.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    private func setupUI() {
        doneButton.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        doneButton.layer.cornerRadius = 5
        doneButton.layer.shadowColor = UIColor.black.cgColor
        doneButton.layer.shadowOpacity = 0.2
        doneButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        doneButton.layer.shadowRadius = 10
        
        wordTextField.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        wordTextField.layer.shadowColor = UIColor.black.cgColor
        wordTextField.layer.shadowOpacity = 0.2
        wordTextField.layer.shadowOffset = CGSize(width: 0, height: 5)
        wordTextField.layer.shadowRadius = 10
        
        translateLabel.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        translateLabel.layer.shadowColor = UIColor.black.cgColor
        translateLabel.layer.shadowOpacity = 0.2
        translateLabel.layer.shadowOffset = CGSize(width: 0, height: 5)
        translateLabel.layer.shadowRadius = 10
    }
    
    @objc private func translateWord(timer: Timer) {
       guard let textField = timer.userInfo as? UITextField,
             let text = textField.text, !text.isEmpty,
             let word = textField.text, !word.isEmpty else { return }

       yandexDictManager.lookup(word: word, language: "en-ru") { [weak self] result in
           DispatchQueue.main.async {
               switch result {
               case .success(let response):
                   self?.translateLabel.text = response.def.first?.tr.first?.text ?? "Перевод не найден"
               case .failure(let error):
                   self?.translateLabel.text = "Ошибка: \(error.localizedDescription)"
               }
           }
       }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension NewWordsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Invalidate the existing timer if it's running
            typingTimer?.invalidate()

            // Start a new timer
            typingTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(translateWord), userInfo: textField, repeats: false)

            return true
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
