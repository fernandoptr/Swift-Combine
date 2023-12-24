//
//  SearchPostsViewModelTests.swift
//  Building Real-Case AppTests
//
//  Created by Fernando Putra on 24/12/23.
//

import XCTest
import Combine
@testable import Building_Real_Case_App

final class SearchPostsViewModelTests: XCTestCase {
    var service: MockJSONPlaceholderAPIService!
    var sut: SearchPostsViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        service = MockJSONPlaceholderAPIService()
        sut = SearchPostsViewModel(service: service)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        service = nil
        sut = nil
        cancellables = nil
    }

    func testSetupBindingsWithEmptyQuery() {
        // Given
        let expectation = expectation(description: "Query input should be empty")

        // When
        sut.$queryInput
            .sink { query in
                // Then
                XCTAssertTrue(query.isEmpty, "Query input should be empty")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testSetupBindingsWithInputtedQuery() {
        // Given
        let expectation = expectation(description: "Query input should not be empty")
        let expectedQuery = "lala"
        var queryInputChangePerformed = false

        // When
        sut.$queryInput
            .dropFirst() // Drop the initial empty query input
            .sink { query in
                // Then
                queryInputChangePerformed = true
                XCTAssertEqual(query, expectedQuery, "Query input should be equal to the expected query")
                XCTAssertTrue(queryInputChangePerformed, "The action for query input change was performed")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.queryInput = expectedQuery
        wait(for: [expectation], timeout: 1)
    }

    func testFetchPostsSuccess() {
        // Given
        let query = "Title 1"
        let expectedResult = [
            PostDetail(userId: 1, postId: 1, title: "Title 1", body: "Body 1", username: "lala1")
        ]
        let expectedStates: [String] = ["initial", "loading", "success"]
        let expectation = expectation(description: "Fetch posts successful")

        // When
        var stateValues: [String] = []
        sut.$state
            .sink { state in
                stateValues.append(state.rawValue)
                // Then
                if stateValues.count == expectedStates.count {
                    XCTAssertEqual(stateValues, expectedStates, "The state transition should be equal to the expected states")
                    expectation.fulfill()
                }
                if case .success(let posts) = state {
                    XCTAssertEqual(posts, expectedResult, "Fetched posts should match the expected result")
                }
            }
            .store(in: &cancellables)

        sut.queryInput = query
        wait(for: [expectation], timeout: 1)
    }

    func testFetchPostsError() throws {
        // Given
        let sampleQuery = "Title 1"
        let expectedStates: [String] = ["initial", "loading", "error"]
        let expectation = expectation(description: "Fetch posts failed with error")

        // When
        sut = SearchPostsViewModel(service: MockErrorJSONPlaceholderAPIService())
        var stateValues: [String] = []
        sut.$state
            .sink { state in
                stateValues.append(state.rawValue)
                // Then
                if stateValues.count == expectedStates.count {
                    XCTAssertEqual(stateValues, expectedStates, "The state transition should be equal to the expected states")
                    expectation.fulfill()
                }
                if case .error(let error) = state {
                    // Then
                    XCTAssertNotNil(error, "Received error should be not nil")
                }
            }
            .store(in: &cancellables)

        sut.queryInput = sampleQuery
        wait(for: [expectation], timeout: 1)
    }
}
