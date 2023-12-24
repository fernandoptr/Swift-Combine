//
//  MockJSONPlaceholderAPIService.swift
//  Building Real-Case AppTests
//
//  Created by Fernando Putra on 24/12/23.
//

import Foundation
import Combine
@testable import Building_Real_Case_App

class MockJSONPlaceholderAPIService: JSONPlaceholderAPIService {
    override func fetchUsers() -> AnyPublisher<[User], Error> {
        let data = [
            User(id: 1, name: "lala", username: "lala1", email: "lala@mail.com"),
            User(id: 2, name: "lele", username: "lele1", email: "lele@mail.com"),
            User(id: 3, name: "lili", username: "lili1", email: "lili@mail.com"),
        ]
        return Just(data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    override func fetchPosts() -> AnyPublisher<[Post], Error> {
        let data = [
            Post(userId: 1, id: 1, title: "Title 1", body: "Body 1"),
            Post(userId: 4, id: 1, title: "Title 1", body: "Body 1"),
            Post(userId: 2, id: 2, title: "Title 2", body: "Body 2"),
            Post(userId: 3, id: 3, title: "Title 3", body: "Body 3"),
        ]
        return Just(data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class MockErrorJSONPlaceholderAPIService: JSONPlaceholderAPIService {
    private let error = URLError(.notConnectedToInternet)
    
    override func fetchUsers() -> AnyPublisher<[User], Error> {
        return Fail(error: error).eraseToAnyPublisher()
    }
    
    override func fetchPosts() -> AnyPublisher<[Post], Error> {
        return Fail(error: error).eraseToAnyPublisher()
    }
}
