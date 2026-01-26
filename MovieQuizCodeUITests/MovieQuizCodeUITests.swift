//
//  MovieQuizCodeUITests.swift
//  MovieQuizCodeUITests
//
//  Created by Dmitry Batorevich on 10.01.2026.
//

import XCTest

final class MovieQuizCodeUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testScreenCast() {
        let app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.buttons["Да"].firstMatch.tap()/*[[".buttons.containing(.staticText, identifier: \"Да\").firstMatch",".tap()",".press(forDuration: 0.5)",".otherElements.buttons[\"Да\"].firstMatch",".buttons[\"Да\"].firstMatch"],[[[-1,4,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,1]]@END_MENU_TOKEN@*/
    }
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["PosterImageView"]
        //XCTAssertTrue(firstPoster.exists)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["yesButton"].tap()
        sleep(3)
        
        let secondPoster = app.images["PosterImageView"]
        //XCTAssertTrue(secondPoster.exists)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["counterLabel"]
        
        XCTAssertFalse(firstPosterData == secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        let firstPoster = app.images["PosterImageView"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["noButton"].tap()
        sleep(3)
        
        let secondPoster = app.images["PosterImageView"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["counterLabel"]
        XCTAssertFalse(firstPosterData == secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testAlert() {
        for _ in 0...9 {
            app.buttons["yesButton"].tap()
        }
        sleep(3)
        let alert = app.alerts.firstMatch
        //let alert = app.alerts["Этот раунд окончен!"]
        let alertTitle = alert.staticTexts.firstMatch.label
        //print("Alert title: \(alertTitle)")
        let buttonText = alert.buttons.firstMatch.label
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(buttonText, "Сыграть ещё раз")
        XCTAssertEqual(alertTitle, "Этот раунд окончен!")
    }
    
    func testAlertDismiss() {
        for _ in 0...9 {
            app.buttons["noButton"].tap()
        }
        sleep(3)
        let alert = app.alerts.firstMatch
        alert.buttons.firstMatch.tap()
        sleep(3)
        
        let indexLabel = app.staticTexts["counterLabel"]
        XCTAssertTrue(indexLabel.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
        
    }
    
    @MainActor
    func testExample() throws {
        
        let app = XCUIApplication()
        app.launch()
        
        
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
