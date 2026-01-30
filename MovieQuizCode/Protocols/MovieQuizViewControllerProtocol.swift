//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 25.01.2026.
//

import Foundation
protocol MovieQuizViewControllerProtocol: AnyObject {
    func showFirstScreen(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func changeStateButton(isEnabled: Bool)
    func showNetworkError(message: String)
}

