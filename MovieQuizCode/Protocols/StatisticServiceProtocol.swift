//
//  StatisticServiceProtocol.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 08.11.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    var correctAnswers: Int { get }
    
    func store(correct count: Int, total amount: Int)
    
}
