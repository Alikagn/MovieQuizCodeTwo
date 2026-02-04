//
//  MocQuestionFactory.swift
//  MovieQuizCode
//
//  Created by Dmitry Batorevich on 03.02.2026.
//

import UIKit

final class MockQuestionFactory: QuestionFactoryProtocol {
    private weak var delegate: QuestionFactoryDelegate?
    
    // Храним названия картинок и ответы, а не готовые QuizQuestion
    private let questionData: [(imageName: String, text: String, correctAnswer: Bool)] = [
        ("The Godfather", "Рейтинг этого фильма больше, чем 6?", true),
        ("The Dark Knight", "Рейтинг этого фильма больше, чем 6?", true),
        ("Kill Bill", "Рейтинг этого фильма больше, чем 6?", true),
        ("The Avengers", "Рейтинг этого фильма больше, чем 6?", true),
        ("Deadpool", "Рейтинг этого фильма больше, чем 6?", true),
        ("The Green Knight", "Рейтинг этого фильма больше, чем 6?", true),
        ("Old", "Рейтинг этого фильма больше, чем 6?", false),
        ("The Ice Age Adventures of Buck Wild", "Рейтинг этого фильма больше, чем 6?", false),
        ("Tesla", "Рейтинг этого фильма больше, чем 6?", false),
        ("Vivarium", "Рейтинг этого фильма больше, чем 6?", false)
    ]
    
    // Кэш для изображений
    private var imageCache: [String: Data] = [:]
    
    init(delegate: QuestionFactoryDelegate?) {
        self.delegate = delegate
    }
    
    func loadData() {
        // Предзагружаем все изображения в кэш
        preloadImages()
        
        // Сообщаем делегату, что данные загружены
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.delegate?.didLoadDataFromServer()
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            // Выбираем случайный вопрос
            guard let randomData = self.questionData.randomElement() else {
                DispatchQueue.main.async {
                    self.delegate?.didReceiveNextQuestion(question: nil)
                }
                return
            }
            
            // Получаем данные изображения
            let imageData = self.getImageData(for: randomData.imageName)
            
            // Создаем QuizQuestion с Data
            let question = QuizQuestion(
                image: imageData,
                text: randomData.text,
                correctAnswer: randomData.correctAnswer
            )
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func preloadImages() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            for data in self.questionData {
                _ = self.getImageData(for: data.imageName)
            }
        }
    }
    
    private func getImageData(for imageName: String) -> Data {
        // Проверяем кэш
        if let cachedData = imageCache[imageName] {
            return cachedData
        }
        
        // Загружаем из Assets
        guard let uiImage = UIImage(named: imageName) else {
            print("⚠️ Image not found in Assets: \(imageName)")
            return createPlaceholderImageData(for: imageName)
        }
        
        // Конвертируем в Data (пробуем PNG, потом JPEG)
        if let pngData = uiImage.pngData() {
            imageCache[imageName] = pngData
            return pngData
        } else if let jpegData = uiImage.jpegData(compressionQuality: 0.9) {
            imageCache[imageName] = jpegData
            return jpegData
        } else {
            let placeholder = createPlaceholderImageData(for: imageName)
            imageCache[imageName] = placeholder
            return placeholder
        }
    }
    
    private func createPlaceholderImageData(for imageName: String) -> Data {
        let size = CGSize(width: 300, height: 450)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            UIColor.darkGray.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .medium),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]
            
            let title = imageName.replacingOccurrences(of: " ", with: "\n")
            let attributedString = NSAttributedString(string: title, attributes: attributes)
            let stringSize = attributedString.size()
            
            attributedString.draw(
                in: CGRect(
                    x: (size.width - stringSize.width) / 2,
                    y: (size.height - stringSize.height) / 2,
                    width: stringSize.width,
                    height: stringSize.height
                )
            )
        }
        
        return image.pngData() ?? Data()
    }
}
