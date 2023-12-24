//
//  User.swift
//  Building Real-Case App
//
//  Created by Fernando Putra on 21/12/23.
//

import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let name: String
    let username: String
    let email: String
}
