//
//  MoveQuizPrezenter.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 13.01.2026.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol!
    private var alertPresenter: AlertPresenterProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        // Создаем AlertPresenter внутри Presenter
        if let vc = viewController as? AlertPresenterDelegate {
            self.alertPresenter = AlertPresenter(delegate: vc)
        }
        
        statisticService = StatisticService()
        questionFactory = MockQuestionFactory(delegate: self)
        //questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(error: any Error) {
        viewController?.hideLoadingIndicator()
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showFirstScreen(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    //
    func restartGame () {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    // Конвертация во вью модель
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func setCurrentQuestion (question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
    }
    
    // Обработчик нажатия на кнопку "Да"
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func makeResultsMessage() -> String {
        statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
        
        let bestGame = statisticService?.bestGame
        
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(self.questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame?.correct ?? 0)/\(bestGame?.total ?? 1)"
        + " (\(bestGame?.date.dateTimeString ?? "0")"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? "00"))%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
    
    // Обработка ответа пользователя
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            viewController?.hideLoadingIndicator()
            self.proceedToNextQuestionOrResults()
            viewController?.changeStateButton(isEnabled: true)
            viewController?.hideLoadingIndicator()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            let text = makeResultsMessage()
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть ещё раз",
                completion: { [weak self] in
                    guard let self else { return }
                    self.restartGame()
                    questionFactory?.requestNextQuestion()
                })
            alertPresenter?.makeAlert(alertModel: alertModel)
        }
        else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
