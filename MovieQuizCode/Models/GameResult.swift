//
//  GameResult.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 08.11.2025.
//

import Foundation

struct GameResult: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    // метод сравнения по количеству верных ответов
        func isBetterThan(_ another: GameResult) -> Bool {
            correct > another.correct
        }
}
