import UIKit
import Firebase
import FirebaseFirestore

class WordManager {
    
    static let shared = WordManager()
    private let firestore = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    private let wordsKey = "words"
    
    var words: [Word] = []
    
    private init() {}
    
    func loadWords(completion: @escaping (Result<[Word], Error>) -> Void) {        
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        firestore.collection("users").document(userId).collection("words").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            var loadedWords: [Word] = []
            snapshot?.documents.forEach { document in
                if let spelling = document.data()["spelling"] as? String,
                   let translation = document.data()["translation"] as? String {
                    let word = Word(spelling: spelling, translation: translation)
                    loadedWords.append(word)
                }
            }
            print("firestore")

            self.words = loadedWords
            self.saveWordsToUserDefaults()
            completion(.success(loadedWords))
            return
        }
        
        if let savedWords = userDefaults.object(forKey: wordsKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedWords = try? decoder.decode([Word].self, from: savedWords) {
                print("userdefaults")
                print(loadedWords)
                words = loadedWords
                completion(.success(loadedWords))
                return
            }
        }
    }
    
    func saveWordsToUserDefaults() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(words) {
            userDefaults.set(encoded, forKey: wordsKey)
        }
    }
    
    func loadWordsFromUserDefaults() {
        if let savedWords = userDefaults.object(forKey: wordsKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedWords = try? decoder.decode([Word].self, from: savedWords) {
                words = loadedWords
            }
        }
    }
    
    func saveWordsToFirestore(completion: @escaping (Error?) -> Void) {
        print("saveWordsToFirestore")
        print(words)
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let wordsCollection = firestore.collection("users").document(userId).collection("words")
        
        
        let batch = firestore.batch()
        
        // Добавление новых данных
        self.words.forEach { word in
            let docRef = wordsCollection.document()
            batch.setData([
                "spelling": word.spelling,
                "translation": word.translation
            ], forDocument: docRef)
        }
        
        batch.commit { error in
            completion(error)
        }
        
    }
    
    func deleteFirestore(completion: @escaping (Error?) -> Void) {
        print("saveWordsToFirestore")
        print(words)
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let wordsCollection = firestore.collection("users").document(userId).collection("words")
        
        
        let batch = firestore.batch()
        
        // Добавление новых данных
        wordsCollection.getDocuments { snapshot, error in
            if let error = error {
                completion(error)
                return
            }
            
            // Удаление старых данных
            snapshot?.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
        }
    }
    
    func addWord(_ word: Word) {
        words.append(word)
        saveWordsToUserDefaults()
        saveWordsToFirestore { _ in
            
        }
    }
    
    func removeAll() {
        words.removeAll ()
        saveWordsToUserDefaults()
        saveWordsToFirestore { _ in
            
        }
    }
    
    func clearUserDefaults() {
        userDefaults.set(nil, forKey: wordsKey)
    }
}
