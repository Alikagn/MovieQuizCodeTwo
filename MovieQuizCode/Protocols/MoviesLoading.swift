//
//  MoviesLoading.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 31.12.2025.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
