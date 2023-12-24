//
//  JSONPlaceholderAPIService.swift
//  Building Real-Case App
//
//  Created by Fernando Putra on 21/12/23.
//

import Foundation
import Combine

protocol JSONPlaceholderAPIServiceProtocol {
    func fetchUsers() -> AnyPublisher<[User], Error>
    func fetchPosts() -> AnyPublisher<[Post], Error>
}

class JSONPlaceholderAPIService: JSONPlaceholderAPIServiceProtocol {
    private let baseURL = "https://jsonplaceholder.typicode.com"

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchUsers() -> AnyPublisher<[User], Error> {
        let url = URL(string: "\(baseURL)/users")!
        return fetchData(for: url)
    }

    func fetchPosts() -> AnyPublisher<[Post], Error> {
        let url = URL(string: "\(baseURL)/posts")!
        return fetchData(for: url)
    }

    private func fetchData<T: Decodable>(for url: URL) -> AnyPublisher<T, Error> {
        return session.dataTaskPublisher(for: url)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
