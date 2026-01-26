//
//  QuestionFactoryDelegate.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 01.11.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(error: Error)
}
