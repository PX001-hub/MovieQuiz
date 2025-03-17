import Foundation

enum MovieError: Error {
    case networkError
    case decodingError
}

final class MovieService {
    private let baseURL = "https://moviesdatabase.p.rapidapi.com"
    private let apiKey = "cd2cc3cce6msh222c73439b0be68p1b2f37jsn3703ee221a81"
    
    func fetchMovies() async throws -> [Movie] {
        guard let url = URL(string: "\(baseURL)/titles?list=top_rated_250") else {
            throw MovieError.networkError
        }
        
        var request = URLRequest(url: url)
        request.addValue("moviesdatabase.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MovieError.networkError
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(MovieResponse.self, from: data)
            return result.results
        } catch {
            print("Decoding error: \(error)")
            throw MovieError.decodingError
        }
    }
}

struct MovieResponse: Codable {
    let results: [Movie]
} 