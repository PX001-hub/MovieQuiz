import UIKit

protocol ResultAlertPresenterProtocol {
    func showAlert(score: Int, completion: @escaping () -> Void)
}

final class ResultAlertPresenter: ResultAlertPresenterProtocol {
    weak var viewController: UIViewController?
    private let statisticService: StatisticService
    
    init(viewController: UIViewController, statisticService: StatisticService) {
        self.viewController = viewController
        self.statisticService = statisticService
    }
    
    func showAlert(score: Int, completion: @escaping () -> Void) {
        statisticService.store(correct: score, total: 10)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let bestGameDateString = statisticService.bestGameDate.map { 
            dateFormatter.string(from: $0) 
        } ?? "Нет данных"
        
        let accuracy = String(format: "%.1f", statisticService.calculateAccuracy())
        
        let alert = UIAlertController(
            title: "Раунд завершен!",
            message: """
                Ваш результат: \(score)/10
                Количество сыгранных квизов: \(statisticService.gamesCount)
                Рекорд: \(statisticService.bestScore) (\(bestGameDateString))
                Средняя точность: \(accuracy)%
                """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "Сыграть еще раз",
            style: .default,
            handler: { _ in completion() }
        ))
        
        viewController?.present(alert, animated: true)
    }
} 