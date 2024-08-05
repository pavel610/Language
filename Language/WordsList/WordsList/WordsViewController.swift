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
    lazy var indicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private let wordManager = WordManager.shared
    private let authManager = AuthManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(clear), name: .removeAll, object: nil)
    }

    
    // MARK: - Actions
    private func setupIndicator() {
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            indicator.widthAnchor.constraint(equalToConstant: 30),
            indicator.heightAnchor.constraint(equalToConstant: 30)
        ])
        indicator.startAnimating()
    }
    
    @IBAction func DeleteWordsButtonTapped(_ sender: Any) {
        wordManager.removeAll()
        tableView.reloadData()
        NotificationCenter.default.post(name: .didDeleteWords, object: nil)
    }
    
    @objc private func clear() {
        wordManager.removeAllExceptFirestore()
        tableView.reloadData()
        NotificationCenter.default.post(name: .didDeleteWords, object: nil)
    }
    
    @IBAction func NewWordButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "MyNewWords", sender: self)
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
        wordManager.addWord(word)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        NotificationCenter.default.post(name: .didAddNewWord, object: nil, userInfo: ["word": word])
    }
}

// MARK: - UITableViewDataSource
extension WordsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordManager.getWords().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath) as? TableCell else {
            return UITableViewCell()
        }
        cell.config(word: wordManager.getWords()[indexPath.row])
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
    public static let didAddNewWord = Notification.Name("didAddNewWord")
    public static let didDeleteWords = Notification.Name("didDeleteWords")
    public static let removeAll = Notification.Name("removeAll")
}

