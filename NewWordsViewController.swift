//
//  NewWordsViewController.swift
//  Language
//
//  Created by Павел on 07.07.2024.
//

import UIKit

class NewWordsViewController: UIViewController {

    @IBOutlet weak var wordTextField: UITextField!
    @IBOutlet weak var TranslateLabel: UILabel!
    @IBOutlet weak var DoneButton: UIButton!
    
    private let yandexDictManager = YandexDictManager()
    
    protocol NewWordDelegate: AnyObject {
        func didAddNewWord(_ word: Word)
    }
    
    weak var delegate: NewWordDelegate?

    @IBAction func DoneButtonTapped(_ sender: Any) {
        translateWord()

        guard let newSpelling = wordTextField.text,
              let newTranslation = TranslateLabel.text,
              !newSpelling.isEmpty, !newTranslation.isEmpty else { return }

        let newWord = Word(spelling: newSpelling, translation: newTranslation)
        delegate?.didAddNewWord(newWord)
        
        TranslateLabel.text = ""
        wordTextField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordTextField.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        TranslateLabel.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)

        setupUI()
        wordTextField.delegate = self
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Очищаем TranslateLabel каждый раз при открытии экранаъъ
        TranslateLabel.text = ""
    }

    private func setupUI() {
        DoneButton.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        DoneButton.layer.cornerRadius = 5
        DoneButton.layer.shadowColor = UIColor.black.cgColor
        DoneButton.layer.shadowOpacity = 0.2
        DoneButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        DoneButton.layer.shadowRadius = 10
        
        wordTextField.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        wordTextField.layer.shadowColor = UIColor.black.cgColor
        wordTextField.layer.shadowOpacity = 0.2
        wordTextField.layer.shadowOffset = CGSize(width: 0, height: 5)
        wordTextField.layer.shadowRadius = 10
        
        TranslateLabel.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        TranslateLabel.layer.shadowColor = UIColor.black.cgColor
        TranslateLabel.layer.shadowOpacity = 0.2
        TranslateLabel.layer.shadowOffset = CGSize(width: 0, height: 5)
        TranslateLabel.layer.shadowRadius = 10
    }
    
    private func translateWord() {
        guard let word = wordTextField.text, !word.isEmpty else { return }
        
        yandexDictManager.lookup(word: word, language: "en-ru") { [weak self] result in
            switch result {
            case .success(let dictionaryResponse):
                if let translation = dictionaryResponse.def.first?.tr.first?.text {
                    DispatchQueue.main.async {
                        self?.TranslateLabel.text = translation
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.TranslateLabel.text = "Перевод не найден"
                    }
                }
            case .failure(let error):
                print("Ошибка при переводе: \(error)")
                DispatchQueue.main.async {
                    self?.TranslateLabel.text = "Ошибка перевода"
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension NewWordsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        translateWord()
        return true
    }
}
