//
//  Array+Extensions.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 30.10.2025.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
