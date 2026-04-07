//
//  PhotoDTO.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation

// Pexels APIから取得する画像データ
struct PhotoDTO: Decodable {
    let id: Int
    let photographer: String
    let src: PhotoSourceDTO
}

// 画像URL情報
struct PhotoSourceDTO: Decodable {
    let medium: String
    let original: String
}
