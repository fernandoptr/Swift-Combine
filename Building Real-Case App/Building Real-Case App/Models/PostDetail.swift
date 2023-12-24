//
//  PostDetail.swift
//  Building Real-Case App
//
//  Created by Fernando Putra on 21/12/23.
//

import Foundation

struct PostDetail: Identifiable, Equatable {
    let userId: Int
    let postId: Int
    let title: String
    let body: String
    let username: String

    var id: Int { postId }
}
