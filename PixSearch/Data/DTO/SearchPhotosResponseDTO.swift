//
//  SearchPhotosResponseDTO.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation

// Pexels Search APIのレスポンス全体
struct SearchPhotosResponseDTO: Decodable {
    let photos: [PhotoDTO]
}
