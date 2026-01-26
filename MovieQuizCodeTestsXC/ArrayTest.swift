//
//  ArrayTest.swift
//  MovieQuizCodeTestsXC
//
//  Created by Dmitry Batorevich on 07.01.2026.
//

import XCTest
@testable import MovieQuizCode

class ArrayTest: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [1,1,2,3,4,5]
        // When
        let value = array[safe: 2]
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1,1,2,3,4,5]
        // When
        let value = array[safe: 20]
        // Then
        XCTAssertNil(value)
    }
}
