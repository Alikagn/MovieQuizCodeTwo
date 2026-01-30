//
//  ViewController.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 17.10.2025.
//

import UIKit

class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    private var alertPresenter: AlertPresenterProtocol? // в презентер!
    private var presenter: MovieQuizPresenter!
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.text = "Вопрос:"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.text = "1/10"
        label.textColor = .white
        // Устанавливаем contentHuggingPriority для горизонтальной оси
        label.setContentHuggingPriority(UILayoutPriority(252), for: .horizontal)
        label.font = .boldSystemFont(ofSize: 20)
        label.accessibilityIdentifier = "counterLabel"
        return label
    }()
    
    private lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.text = "Рейтинг этого фильма меньше, чем 5?"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 23)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear // Можно заменить на .red для отладки
        return label
    }()
    
    // Контейнер для центрирования ratingLabel
    private lazy var ratingContainerView: UIStackView = {
        let container = UIStackView()
        container.axis = .horizontal
        container.distribution = .fill
        container.alignment = .center
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 13, left: 42, bottom: 13, right: 42)
        container.addArrangedSubview(ratingLabel)
        return container
    }()
    
    private lazy var topStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 0
        
        // Добавляем лейблы в стек
        stack.addArrangedSubview(questionLabel)
        stack.addArrangedSubview(counterLabel)
        
        return stack
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.accessibilityIdentifier = "PosterImageView"
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var yesButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Да", for: .normal)
        button.backgroundColor = .white
        button.tintColor = .black
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 12
        button.accessibilityIdentifier = "yesButton"
        //button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(yesButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var noButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Нет", for: .normal)
        button.backgroundColor = .white
        button.tintColor = .black
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 12
        button.accessibilityIdentifier = "noButton"
        //button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.addTarget(self, action: #selector(noButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20
        
        // Задаем высоту всего стека
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Добавляем кнопки в стек
        stack.addArrangedSubview(noButton)
        stack.addArrangedSubview(yesButton)
        return stack
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 20
        
        stack.addArrangedSubview(topStackView)
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(ratingContainerView) // используем контейнер вместо ratingLabel
        stack.addArrangedSubview(buttonsStackView)
        // stack.addArrangedSubview(activityIndicator)
        return stack
    }()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        setupView()
        alertPresenter = AlertPresenter(delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        super.viewDidLoad()
    }
    
    private func setupView() {
        // Добавляем все элементы на view
        addSubviews()
        // Устанавливаем констрейнты
        setupConstraints()
    }
    
    private func addSubviews() {
        // Добавляем все элементы на view
        [verticalStackView /*topStackView, imageView, ratingLabel, buttonsStackView*/].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        // Устанавливаем aspect ratio для imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let aspectRatioConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3/2)
        aspectRatioConstraint.priority = .required
        
        NSLayoutConstraint.activate([
            // Констрейнты для verticalStackView
            verticalStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            verticalStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            verticalStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            verticalStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
            // Aspect ratio для imageView
            aspectRatioConstraint,
            // Фиксированная ширина для ratingLabel
            ratingLabel.widthAnchor.constraint(equalToConstant: 251),
            // Минимальная высота для ratingLabel чтобы обеспечить место для двух строк
            ratingLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            //Констрейнты для activityIndicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // Обработчик нажатия на кнопку "Да"
    @objc private func yesButtonTapped() {
        // Блокируем кнопки на время загрузки
        changeStateButton(isEnabled: false)
        
        presenter.yesButtonClicked()
        showLoadingIndicator()
    }
    
    // Обработчик нажатия на кнопку "Нет"
    @objc private func noButtonTapped() {
        // Блокируем кнопки на время загрузки
        changeStateButton(isEnabled: false)
        
        presenter.noButtonClicked()
        showLoadingIndicator()
    }
    
    // Вывод первого вопроса на экран
    func showFirstScreen(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        ratingLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    //
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        
        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self else { return }
            self.presenter.restartGame()
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
  
    func show(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.green.cgColor : UIColor.red.cgColor
        imageView.layer.cornerRadius = 20
        activityIndicator.color = isCorrectAnswer ? .green : .red
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self else { return }
            self.presenter.restartGame()
    }
        
        alertPresenter?.makeAlert(alertModel: model)
        //activityIndicator.startAnimating()
    }
    // delete
    /*
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    */
    func changeStateButton(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
