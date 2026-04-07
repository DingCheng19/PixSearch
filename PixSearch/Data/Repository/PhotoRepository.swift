//
//  PhotoRepository.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation

final class PhotoRepository : PhotoRepositoryProtocol {

    private let networkService = NetworkService()

    // Pexels APIから画像データを取得し、画面表示用のModelに変換する
    func searchPhotos(query: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        networkService.searchPhotos(query: query) { result in
            switch result {
            case .success(let data):
                // レスポンスが空の場合は検索結果0件として扱う
                guard !data.isEmpty else {
                    completion(.success([]))
                    return
                }

                do {
                    let response = try JSONDecoder().decode(SearchPhotosResponseDTO.self, from: data)
                    let photos = response.photos.map { Photo(dto: $0) }
                    completion(.success(photos))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
