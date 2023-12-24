//
//  SearchPostsView.swift
//  Building Real-Case App
//
//  Created by Fernando Putra on 21/12/23.
//

import SwiftUI

struct SearchPostsView: View {
    @StateObject private var viewModel = SearchPostsViewModel(service: JSONPlaceholderAPIService())

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .initial:
                    stateView(systemName: "doc.text.magnifyingglass", message: "Enter a title above to find matching posts")
                case .loading:
                    ProgressView()
                case .success(let posts):
                    if posts.isEmpty {
                        stateView(systemName: "folder.badge.questionmark", message: "No results found. Try a different title")
                    } else {
                        postsList(with: posts)
                    }
                case .error:
                    stateView(systemName: "exclamationmark.warninglight", message: "Oops! Something went wrong. Try again later")
                }
            }
            .searchable(text: $viewModel.queryInput, prompt: "Search for posts by title")
        }
    }

    private func stateView(systemName: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: systemName)
                .font(.system(size: 64))
            Text(message)
                .font(.title3)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
    }

    private func postsList(with posts: [PostDetail]) -> some View {
        List(posts) { post in
            VStack(alignment: .leading) {
                Text(post.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(post.body)
                    .font(.caption)
                    .lineLimit(2)
                    .padding(.top, 4)
                HStack {
                    Spacer()
                    Text("@\(post.username)")
                        .font(.footnote)
                        .foregroundStyle(.blue)
                }
                .padding(.top, 8)
            }
        }
    }
}

#Preview {
    SearchPostsView()
}
