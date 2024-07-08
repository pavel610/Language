//
//  WordsViewController.swift
//  Language
//
//  Created by Павел on 06.07.2024.
//

import UIKit

class WordsViewController: UIViewController, NewWordsViewController.NewWordDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var DeleteWordsButton: UIBarButtonItem!
    @IBOutlet weak var NewWordButton: UIBarButtonItem!

    // MARK: - Properties
    var dataSource: [Word] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.layer.backgroundColor = CGColor(red: 255, green: 255, blue: 255, alpha: 1)
        tableView.dataSource = self
        tableView.delegate = self
        loadWords()
    }
    
    // MARK: - Actions
    @IBAction func DeleteWordsButtonTapped(_ sender: Any) {
        dataSource = []
        saveWords()
        tableView.reloadData()
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
        dataSource.append(word)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        saveWords()
    }

    func saveWords() {
        guard let data = try? JSONEncoder().encode(dataSource) else { return }
        UserDefaults.standard.set(data, forKey: "Words")
    }

    func loadWords() {
        guard let data = UserDefaults.standard.data(forKey: "Words"),
              let savedWords = try? JSONDecoder().decode([Word].self, from: data) else { return }
        dataSource = savedWords
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
