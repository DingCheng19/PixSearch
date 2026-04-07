//
//  PhotoRepository.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation
import RxSwift

final class PhotoRepository : PhotoRepositoryProtocol {
    private let networkService = NetworkService()

    // Pexels APIから画像データを取得し、画面表示用のModelに変換する
    func searchPhotos(query: String) -> Single<[Photo]> {
        Single.create { [weak self] single in
            guard let self = self else {
                single(.failure(NSError(domain: "PhotoRepository", code: -1)))
                return Disposables.create()
            }

            self.networkService.searchPhotos(query: query) { result in
                switch result {
                case .success(let data):
                    guard !data.isEmpty else {
                        single(.success([]))
                        return
                    }

                    do {
                        let response = try JSONDecoder().decode(SearchPhotosResponseDTO.self, from: data)
                        let photos = response.photos.map { Photo(dto: $0) }
                        single(.success(photos))
                    } catch {
                        single(.failure(error))
                    }

                case .failure(let error):
                    single(.failure(error))
                }
            }

            return Disposables.create()
        }
    }
}
