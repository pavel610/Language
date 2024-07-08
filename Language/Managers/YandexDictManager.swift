import Foundation

class YandexDictManager {
    private let apiKey = "dict.1.1.20240703T175555Z.4dfd377513776e4f.d4b5d7807642f9b3cbd2775a69c80eeb27546088" 
    private let apiUrl = "https://dictionary.yandex.net/api/v1/dicservice.json/lookup"
    
    func lookup(word: String, language: String, completion: @escaping (Result<DictionaryResponse, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: apiUrl) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "lang", value: language),
            URLQueryItem(name: "text", value: word)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else { return }
            
            do {
                let dictionaryResponse = try JSONDecoder().decode(DictionaryResponse.self, from: data)
                completion(.success(dictionaryResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}

struct DictionaryResponse: Codable {
    let head: Head
    let def: [Def]
}

struct Head: Codable {}

struct Def: Codable {
    let text: String
    let pos: String?
    let tr: [Translation]
}

struct Translation: Codable {
    let text: String
    let pos: String?
}
