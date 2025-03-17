import Foundation

final class QuizStatsManager {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let gamesPlayed = "GamesPlayed"
        static let totalCorrectAnswers = "TotalCorrectAnswers"
        static let bestScore = "BestScore"
        static let bestScoreDate = "BestScoreDate"
    }
    
    var gamesPlayed: Int {
        get { userDefaults.integer(forKey: Keys.gamesPlayed) }
        set { userDefaults.set(newValue, forKey: Keys.gamesPlayed) }
    }
    
    var totalCorrectAnswers: Int {
        get { userDefaults.integer(forKey: Keys.totalCorrectAnswers) }
        set { userDefaults.set(newValue, forKey: Keys.totalCorrectAnswers) }
    }
    
    var bestScore: Int {
        get { userDefaults.integer(forKey: Keys.bestScore) }
        set { userDefaults.set(newValue, forKey: Keys.bestScore) }
    }
    
    var bestScoreDate: Date? {
        get { userDefaults.object(forKey: Keys.bestScoreDate) as? Date }
        set { userDefaults.set(newValue, forKey: Keys.bestScoreDate) }
    }
    
    var averageAccuracy: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(totalCorrectAnswers) / (Double(gamesPlayed) * 10.0) * 100
    }
    
    func updateStats(score: Int) {
        gamesPlayed += 1
        totalCorrectAnswers += score
        
        if score > bestScore {
            bestScore = score
            bestScoreDate = Date()
        }
    }
} 