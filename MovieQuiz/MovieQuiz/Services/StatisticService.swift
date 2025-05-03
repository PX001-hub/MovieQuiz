import Foundation

protocol StatisticService {
    var gamesCount: Int { get }
    var totalScore: Int { get }
    var bestScore: Int { get }
    var bestGameDate: Date? { get }
    
    func store(correct count: Int, total: Int)
    func calculateAccuracy() -> Double
}

final class StatisticServiceImplementation: StatisticService {
    private enum Keys {
        static let gamesCount = "games_count"
        static let totalScore = "total_score"
        static let bestScore = "best_score"
        static let bestGameDate = "best_game_date"
    }
    
    private let userDefaults = UserDefaults.standard
    
    var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount) }
    }
    
    var totalScore: Int {
        get { userDefaults.integer(forKey: Keys.totalScore) }
        set { userDefaults.set(newValue, forKey: Keys.totalScore) }
    }
    
    var bestScore: Int {
        get { userDefaults.integer(forKey: Keys.bestScore) }
        set { userDefaults.set(newValue, forKey: Keys.bestScore) }
    }
    
    var bestGameDate: Date? {
        get { userDefaults.object(forKey: Keys.bestGameDate) as? Date }
        set { userDefaults.set(newValue, forKey: Keys.bestGameDate) }
    }
    
    func store(correct count: Int, total: Int) {
        gamesCount += 1
        totalScore += count
        
        if count > bestScore {
            bestScore = count
            bestGameDate = Date()
        }
    }
    
    func calculateAccuracy() -> Double {
        guard gamesCount > 0 else { return 0 }
        return (Double(totalScore) / (Double(gamesCount) * 10.0)) * 100.0
    }
} 