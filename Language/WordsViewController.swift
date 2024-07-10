//
//  WordsViewController.swift
//  Language
//
//  Created by Павел on 06.07.2024.
//

import UIKit
import Firebase

class WordsViewController: UIViewController, NewWordDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var DeleteWordsButton: UIBarButtonItem!
    @IBOutlet weak var NewWordButton: UIBarButtonItem!
    private let wordManager = WordManager.shared
    private let authManager = AuthManager.shared
    
    // MARK: - Properties
    var dataSource: [Word] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(clear), name: .removeAll, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWords()
        authManager.addAuthStateDidChangeListener { [weak self] user in
            if user == nil {
                self?.showAuthorizationAlert()
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func DeleteWordsButtonTapped(_ sender: Any) {
        dataSource = []
        wordManager.removeAll()
        tableView.reloadData()
        NotificationCenter.default.post(name: .didDeleteWords, object: nil)
    }
    
    @objc private func clear() {
        dataSource = []
        wordManager.removeAllExceptFirestore()
        tableView.reloadData()
        NotificationCenter.default.post(name: .didDeleteWords, object: nil)
    }
    
    @IBAction func NewWordButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "MyNewWords", sender: self)
    }
    
    private func showAuthorizationAlert() {
        let alert = UIAlertController(title: "Ошибка", message: "Войдите в аккаунт, чтобы продолжить", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default) {_ in
            self.tabBarController?.selectedIndex = 2
        })
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MyNewWords" {
            guard let destinationVC = segue.destination as? NewWordsViewController else { return }
            destinationVC.delegate = self
        }
    }
    
    // MARK: - Data Source Management
    func didAddNewWord(_ word: Word) {
        dataSource.append(word)
        wordManager.addWord(word)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        NotificationCenter.default.post(name: .didAddNewWord, object: nil, userInfo: ["word": word])
    }
    
    func loadWords() {
        wordManager.loadWords { [weak self] result in
            switch result {
            case .success(let words):
                self?.dataSource = []
                self?.dataSource = words
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to load words: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension WordsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as? TableCell else {
            return UITableViewCell()
        }
        cell.config(word: dataSource[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension WordsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension Notification.Name {
    static let didAddNewWord = Notification.Name("didAddNewWord")
    static let didDeleteWords = Notification.Name("didDeleteWords")
    static let removeAll = Notification.Name("removeAll")
}

