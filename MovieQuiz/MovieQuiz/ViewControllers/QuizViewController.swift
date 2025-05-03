import UIKit

final class QuizViewController: UIViewController {
    // MARK: - UI Elements
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.layer.borderWidth = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var yesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Да", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemGreen
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var noButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нет", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    private let movieService = MovieService()
    private let questionFactory: QuestionFactoryProtocol
    private let statisticService: StatisticService
    private lazy var resultAlertPresenter: ResultAlertPresenterProtocol = {
        ResultAlertPresenter(viewController: self, statisticService: statisticService)
    }()
    
    private var questions: [QuizQuestion] = []
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // MARK: - Init
    
    init(questionFactory: QuestionFactoryProtocol = QuestionFactory(),
         statisticService: StatisticService = StatisticServiceImplementation()) {
        self.questionFactory = questionFactory
        self.statisticService = statisticService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startNewGame()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(imageView)
        view.addSubview(questionLabel)
        view.addSubview(yesButton)
        view.addSubview(noButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.1),
            
            questionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 24),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            yesButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            yesButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            yesButton.heightAnchor.constraint(equalToConstant: 60),
            yesButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            
            noButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            noButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            noButton.heightAnchor.constraint(equalToConstant: 60),
            noButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45)
        ])
    }
    
    // MARK: - Game Logic
    
    private func startNewGame() {
        Task {
            do {
                let movies = try await movieService.fetchMovies()
                questions = movies.prefix(10).map { questionFactory.createQuestion(from: $0) }
                currentQuestionIndex = 0
                correctAnswers = 0
                showQuestion()
            } catch {
                showError()
            }
        }
    }
    
    private func showQuestion() {
        guard currentQuestionIndex < questions.count else {
            showGameResults()
            return
        }
        
        let question = questions[currentQuestionIndex]
        questionLabel.text = question.text
        
        if let url = URL(string: question.image) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }.resume()
        }
        
        imageView.layer.borderColor = UIColor.white.cgColor
        enableButtons(true)
    }
    
    private func checkAnswer(_ userAnswer: Bool) {
        let isCorrect = userAnswer == questions[currentQuestionIndex].correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        
        imageView.layer.borderColor = isCorrect ? UIColor.systemGreen.cgColor : UIColor.systemRed.cgColor
        enableButtons(false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.currentQuestionIndex += 1
            self?.showQuestion()
        }
    }
    
    private func showGameResults() {
        resultAlertPresenter.showAlert(score: correctAnswers) { [weak self] in
            self?.startNewGame()
        }
    }
    
    private func showError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось загрузить данные",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Попробовать снова", style: .default) { [weak self] _ in
            self?.startNewGame()
        })
        
        present(alert, animated: true)
    }
    
    private func enableButtons(_ enabled: Bool) {
        yesButton.isEnabled = enabled
        noButton.isEnabled = enabled
    }
    
    // MARK: - Actions
    
    @objc private func yesButtonTapped() {
        checkAnswer(true)
    }
    
    @objc private func noButtonTapped() {
        checkAnswer(false)
    }
} 