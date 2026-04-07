//
//  Photo.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation

import Foundation

struct Photo {
    let id: Int
    let photographerName: String
    let thumbnailURL: URL?
    let originalURL: URL?
    
    // モックデータ生成用
    init(
        id: Int,
        photographerName: String,
        thumbnailURL: URL?,
        originalURL: URL?
    ) {
        self.id = id
        self.photographerName = photographerName
        self.thumbnailURL = thumbnailURL
        self.originalURL = originalURL
    }
    
    // DTOから画面表示用のModelに変換する
    init(dto: PhotoDTO) {
        self.id = dto.id
        self.photographerName = dto.photographer
        self.thumbnailURL = URL(string: dto.src.medium)
        self.originalURL = URL(string: dto.src.original)
    }
}
