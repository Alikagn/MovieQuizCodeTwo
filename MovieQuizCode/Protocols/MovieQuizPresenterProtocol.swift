//
//  MovieQuizPresenterProtocol.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 01.02.2026.
//

import Foundation

protocol MovieQuizPresenterProtocol {
    func yesButtonClicked()
    func noButtonClicked()
    func restartGame()
    func requestNextQuestion()
}
