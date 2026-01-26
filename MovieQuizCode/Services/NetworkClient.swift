//
//  NetworkClient.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 19.12.2025.
//

import Foundation
/*
 
 */
/// Отвечает за загрузку данных по URL
struct NetworkClient: NetworkRouting {
    // MARK: - Типы ошибок
    private enum NetworkError: Error, LocalizedError {
        // case codeError
        case invalidURL
        case noInternetConnection
        case timeout
        case connectionLost
        case serverError(statusCode: Int)
        case clientError(statusCode: Int)
        case invalidResponse
        case noData
        case decodingFailed
        case unknown(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Неверный URL адрес"
            case .noInternetConnection:
                return "Отсутствует подключение к интернету"
            case .timeout:
                return "Превышено время ожидания"
            case .connectionLost:
                return "Соединение с сервером потеряно"
            case .serverError(let statusCode):
                return "Ошибка сервера: \(statusCode)"
            case .clientError(let statusCode):
                return "Ошибка клиента: \(statusCode)"
            case .invalidResponse:
                return "Некорректный ответ сервера"
            case .noData:
                return "Сервер не вернул данные"
            case .decodingFailed:
                return "Ошибка обработки данных"
            case .unknown(let error):
                return "Неизвестная ошибка: \(error.localizedDescription)"
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .noInternetConnection:
                return "Проверьте подключение к интернету"
            case .timeout:
                return "Попробуйте повторить запрос позже"
            case .serverError:
                return "Сервер временно недоступен. Попробуйте позже"
            case .clientError(let code) where code == 404:
                return "Запрашиваемый ресурс не найден"
            case .clientError(let code) where code == 401 || code == 403:
                return "Проверьте авторизационные данные"
            default:
                return "Попробуйте повторить операцию"
            }
        }
    }
    
    // MARK: - Конфигурация
    private let session: URLSession
    private let timeoutInterval: TimeInterval
    
    init(session: URLSession = .shared, timeoutInterval: TimeInterval = 10.0) {
        self.session = session
        self.timeoutInterval = timeoutInterval
    }
    
    // MARK: - Основной метод
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let task = session.dataTask(with: request) { data, response, error in
            
            // Обрабатываем результат в главном потоке
            DispatchQueue.main.async {
                // 1. Проверяем системные ошибки сети
                if let error = error {
                    let networkError = self.mapSystemError(error)
                    handler(.failure(networkError))
                    return
                }
                
                // 2. Проверяем наличие HTTP-ответа
                guard let httpResponse = response as? HTTPURLResponse else {
                    handler(.failure(NetworkError.invalidResponse))
                    return
                }
                
                // 3. Проверяем статус код ответа
                let statusCode = httpResponse.statusCode
                
                switch statusCode {
                case 200...299:
                    // Успешные коды
                    break
                case 400...499:
                    // Ошибки клиента
                    handler(.failure(NetworkError.clientError(statusCode: statusCode)))
                    self.logError(statusCode: statusCode, url: url)
                    return
                case 500...599:
                    // Ошибки сервера
                    handler(.failure(NetworkError.serverError(statusCode: statusCode)))
                    self.logError(statusCode: statusCode, url: url)
                    return
                default:
                    // Прочие коды
                    handler(.failure(NetworkError.unknown(NSError(
                        domain: "HTTP",
                        code: statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Неожиданный код ответа: \(statusCode)"]
                    ))))
                    self.logError(statusCode: statusCode, url: url)
                    return
                }
                
                // 4. Проверяем наличие данных
                guard let data = data else {
                    handler(.failure(NetworkError.noData))
                    return
                }
                
                // 5. Проверяем, что данные не пустые
                guard !data.isEmpty else {
                    handler(.failure(NetworkError.noData))
                    return
                }
                
                // 6. Проверяем Content-Type (опционально)
                if let mimeType = httpResponse.mimeType {
                    self.validateMimeType(mimeType, handler: handler)
                }
                
                // 7. Успешный результат
                handler(.success(data))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Вспомогательные методы
        
        /// Преобразует системные ошибки в NetworkError
        private func mapSystemError(_ error: Error) -> NetworkError {
            let nsError = error as NSError
            
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorNetworkConnectionLost:
                return .noInternetConnection
            case NSURLErrorTimedOut:
                return .timeout
            case NSURLErrorCancelled:
                return .unknown(error)
            case NSURLErrorBadURL,
                 NSURLErrorUnsupportedURL:
                return .invalidURL
            default:
                return .unknown(error)
            }
        }
    
    /// Проверяет MIME-тип ответа
        private func validateMimeType(_ mimeType: String, handler: @escaping (Result<Data, Error>) -> Void) {
            // Можно добавить проверку на ожидаемые MIME-типы
            let acceptedTypes = ["application/json", "text/json", "text/plain"]
            
            if !acceptedTypes.contains(where: { mimeType.contains($0) }) {
                // Логируем неожиданный тип, но не прерываем выполнение
                print("⚠️ Неожиданный MIME-тип: \(mimeType)")
            }
        }
        
        /// Логирует ошибки HTTP
        private func logError(statusCode: Int, url: URL) {
            print("""
            🔴 Сетевой запрос завершился с ошибкой:
               URL: \(url.absoluteString)
               Status Code: \(statusCode)
               Description: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))
            """)
        }
    /*
     func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
     let request = URLRequest(url: url)
     
     let task = URLSession.shared.dataTask(with: request) { data, response, error in
     // Проверяем, пришла ли ошибка
     if let error {
     handler(.failure(error))
     return
     }
     
     // Проверяем, что нам пришёл успешный код ответа
     if let response = response as? HTTPURLResponse,
     response.statusCode < 200 || response.statusCode >= 300 {
     handler(.failure(NetworkError.codeError))
     print("Ошибка: \(response.statusCode)")
     return
     }
     
     // Возвращаем данные
     guard let data else { return }
     handler(.success(data))
     }
     
     task.resume()
     }
     */
}
