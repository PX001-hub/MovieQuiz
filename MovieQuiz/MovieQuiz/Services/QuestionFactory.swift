import Foundation

protocol QuestionFactoryProtocol {
    func createQuestion(from movie: Movie) -> QuizQuestion
}

final class QuestionFactory: QuestionFactoryProtocol {
    func createQuestion(from movie: Movie) -> QuizQuestion {
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