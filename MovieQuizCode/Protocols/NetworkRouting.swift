//
//  NetworkRouting.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 08.01.2026.
//

import Foundation
protocol NetworkRouting {
    func fetch (url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
