//
//  SearchPostsViewModel.swift
//  Building Real-Case App
//
//  Created by Fernando Putra on 21/12/23.
//

import Foundation
import Combine

class SearchPostsViewModel: ObservableObject {
    @Published var queryInput: String = ""
    @Published var state: AppState<[PostDetail]> = .initial
    private let service: JSONPlaceholderAPIServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(service: JSONPlaceholderAPIServiceProtocol) {
        self.service = service
        setupBindings()
    }
    
    private func setupBindings() {
        $queryInput
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { query in
                if !query.isEmpty {
                    self.fetchPosts(with: query)
                } else {
                    self.state = .initial
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchPosts(with query: String) {
        self.state = .loading
        
        Publishers.CombineLatest(service.fetchUsers(), service.fetchPosts())
            .map { users, posts in
                return posts
                    .filter { post in
                        post.title.lowercased().contains(query.lowercased())
                    }
                    .compactMap { post in
                        guard let user = users.first(where: { $0.id == post.userId }) else {
                            return nil
                        }
                        return PostDetail(userId: user.id, postId: post.id, title: post.title, body: post.body, username: user.username)
                    }
            }
            .sink { completion in
                if case .failure(let error) = completion {
                    self.state = .error(error)
                    print("Error: \(error.localizedDescription)")
                }
            } receiveValue: { posts in
                self.state = .success(posts)
            }
            .store(in: &cancellables)
    }
}
