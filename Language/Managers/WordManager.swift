//
//  WordsManager.swift
//  Language
//
//  Created by Павел Калинин on 04.07.2024.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class WordManager {
    
    static let shared = WordManager()
    private let database = Database.database().reference()
    private let userDefaults = UserDefaults.standard
    private let wordsKey = "words"
    
    var words: [Word] = []
    
    private init() {}
    
    func loadWords(completion: @escaping (Result<[Word], Error>) -> Void) {
        if let savedWords = userDefaults.object(forKey: wordsKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedWords = try? decoder.decode([Word].self, from: savedWords) {
                words = loadedWords
                completion(.success(loadedWords))
                return
            }
        }
        
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        database.child("users").child(userId).child("words").observeSingleEvent(of: .value) { snapshot in
            var loadedWords: [Word] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: String],
                   let spelling = dict["spelling"],
                   let translation = dict["translation"] {
                    let word = Word(spelling: spelling, translation: translation)
                    loadedWords.append(word)
                }
            }
            self.words = loadedWords
            self.saveWordsToUserDefaults()
            completion(.success(loadedWords))
        } withCancel: { error in
            completion(.failure(error))
        }
    }
    
    func saveWordsToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(words) {
            userDefaults.set(encoded, forKey: wordsKey)
        }
    }
    
    func saveWordsToFirebase(completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let wordsDict = words.map { ["spelling": $0.spelling, "translation": $0.translation] }
        database.child("users").child(userId).child("words").setValue(wordsDict) { error, _ in
            completion(error)
        }
    }
    
    func addWord(_ word: Word) {
        words.append(word)
        saveWordsToUserDefaults()
    }
    
    func removeWord(_ word: Word) {
        words.removeAll { $0.spelling == word.spelling && $0.translation == word.translation }
        saveWordsToUserDefaults()
    }
}
