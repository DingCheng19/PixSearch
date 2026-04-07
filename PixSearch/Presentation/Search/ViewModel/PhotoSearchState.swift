//
//  PhotoSearchState.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation

enum PhotoSearchState {
    case initial(message: String)
    case loading
    case loaded([Photo])
    case empty(message: String)
    case error(message: String)
}
