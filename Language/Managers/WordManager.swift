import UIKit
import Firebase
import FirebaseFirestore
import Network
import Combine

class WordManager {
    
    static let shared = WordManager()
    private let firestore = Firestore.firestore()
    private let userDefaults = UserDefaults.standard
    private let wordsKey = "words"
    
    @Published var words: [Word] = []
    
    private init() {
        loadWords { result in
            
        }
    }
    
    func getWords() -> [Word]{
        words
    }

    func loadWords(completion: @escaping (Result<[Word], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        monitor.start(queue: queue)
        
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Интернет доступен, загружаем данные из Firestore
                self.loadWordsFromFirestore(userId: userId, completion: completion)
            } else {
                // Интернет недоступен, загружаем данные из UserDefaults
                self.loadWordsFromUserDefaults(completion: completion)
            }
            monitor.cancel() // Останавливаем мониторинг после выполнения проверки
        }
    }

    private func loadWordsFromFirestore(userId: String, completion: @escaping (Result<[Word], Error>) -> Void) {
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

            self.words = loadedWords
            self.saveWordsToUserDefaults()
            completion(.success(loadedWords))
        }
    }

    private func loadWordsFromUserDefaults(completion: @escaping (Result<[Word], Error>) -> Void) {
        if let savedWords = userDefaults.object(forKey: wordsKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedWords = try? decoder.decode([Word].self, from: savedWords) {
                words = loadedWords
                completion(.success(loadedWords))
            } else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to decode words from UserDefaults"])))
            }
        } else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No words found in UserDefaults"])))
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
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        let wordsCollection = firestore.collection("users").document(userId).collection("words")
        
        // Step 1: Delete all existing documents
        wordsCollection.getDocuments { snapshot, error in
            if let error = error {
                completion(error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No documents found"]))
                return
            }
            
            let deleteBatch = self.firestore.batch()
            documents.forEach { document in
                deleteBatch.deleteDocument(document.reference)
            }
            
            deleteBatch.commit { [self] error in
                if let error = error {
                    completion(error)
                    return
                }
                
                // Step 2: Add new documents
                let addBatch = firestore.batch()
                self.words.forEach { word in
                    let docId = "\(word.spelling.hashValue)"
                    let docRef = wordsCollection.document(docId)
                    addBatch.setData([
                        "spelling": word.spelling,
                        "translation": word.translation
                    ], forDocument: docRef)
                }
                
                addBatch.commit { error in
                    completion(error)
                }
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
        deleteAllWordsFromFirestore { _ in
            
        }
    }
    
    func removeAllExceptFirestore(){
        words.removeAll ()
        saveWordsToUserDefaults()
    }
    
    func clearUserDefaults() {
        userDefaults.set(nil, forKey: wordsKey)
    }
    
    func deleteAllWordsFromFirestore(completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        
        firestore.collection("users").document(userId).collection("words").getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
                return
            }
            
            let batch = self.firestore.batch()
            
            for document in querySnapshot!.documents {
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { error in
                completion(error)
            }
        }
    }

}
