import Foundation

struct QuizQuestion {
    let image: String  // URL or asset name
    let text: String
    let correctAnswer: Bool
    let movieId: Int
    
    static func makeQuestion(from movie: Movie) -> QuizQuestion {
        let rating = movie.rating
        let threshold = Double.random(in: 1...9).rounded()
        let isGreater = rating > threshold
        
        return QuizQuestion(
            image: movie.image,
            text: "Рейтинг этого фильма больше \(Int(threshold))?",
            correctAnswer: isGreater,
            movieId: movie.id
        )
    }
} 