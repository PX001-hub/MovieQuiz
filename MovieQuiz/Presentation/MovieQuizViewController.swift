import UIKit


final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        
        showNextQuestion() // Показать первый вопрос при загрузке экрана
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(true)
        
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkAnswer(false)
        
    }
    
    
    
    
    // MARK: - Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    // Массив вопросов
    let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    // MARK: - Methods
    
    
    
    private func resetImageViewBorder() {
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func setButtonEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // для состояния "Результат квиза"
    struct QuizResultsViewModel {
        // строка с заголовком алерта
        let title: String
        // строка с текстом о количестве набранных очков
        let text: String
        // текст для кнопки алерта
        let buttonText: String
    }
    
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/\(questions.count)" // 1
            let viewModel = QuizResultsViewModel( // 2
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            setButtonEnabled(true)
            resetImageViewBorder() // Сбрасываем цвет рамки перед следующим вопросом
            show(quiz: viewModel) // показать результаты
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            setButtonEnabled(true)
            resetImageViewBorder() // Сбрасываем цвет рамки перед следующим вопросом
            show(quiz: viewModel) // показать следующий вопрос
        }
    }
    // приватный метод, который меняет цвет рамки
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        // метод красит рамку
        //        if isCorrect { // 1
        //               correctAnswers += 1 // 2
        //           }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
        
    }
    
    // Метод для отображения следующего вопроса
    
    private func showNextQuestion() {
        guard currentQuestionIndex < questions.count else {
            showFinalResults() // Показать итоговые результаты, если вопросы закончились
            return
        }
        resetImageViewBorder()
        let currentQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: currentQuestion)
        show(quiz: viewModel)
        //imageView.layer.borderColor = UIColor.white.cgColor
    }
    
    // Приватный метод конвертации, который принимает вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
        return questionStep
    }
    
    // Метод для проверки ответа
    func checkAnswer(_ answer: Bool) {
        setButtonEnabled(false)
        let currentQuestion = questions[currentQuestionIndex]
        
        if currentQuestion.correctAnswer == answer {
            correctAnswers += 1
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == answer)
    }
    
    // Метод для отображения итоговых результатов
    private func showFinalResults() {
        let alert = UIAlertController(
            title: "Викторина завершена",
            message: "Вы ответили правильно на \(correctAnswers) из \(questions.count) вопросов",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Начать заново", style: .default) { [weak self] _ in
            self?.restartQuiz()
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Метод для перезапуска викторины
    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showNextQuestion()
    }
    
    // Метод для показа вопроса на экран
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
}

// MARK: - Models
struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}



