//
//  AppStateEnum.swift
//  Building Real-Case App
//
//  Created by Fernando Putra on 21/12/23.
//

import Foundation

enum AppState<T> {
    case initial, loading, success(T), error(Error)

    var rawValue: String {
        switch self {
        case .initial:
            return "initial"
        case .loading:
            return "loading"
        case .success:
            return "success"
        case .error:
            return "error"
        }
    }
}
