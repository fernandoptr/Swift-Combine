//
//  Post.swift
//  Building Real-Case App
//
//  Created by Fernando Putra on 21/12/23.
//

import Foundation

struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
