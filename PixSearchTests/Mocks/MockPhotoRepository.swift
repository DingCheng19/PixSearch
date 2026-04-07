//
//  MockPhotoRepository.swift
//  PixSearchTests
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation
import RxSwift
@testable import PixSearch

final class MockPhotoRepository: PhotoRepositoryProtocol {

    var result: Result<[Photo], Error> = .success([])

    func searchPhotos(query: String) -> Single<[Photo]> {
        switch result {
        case .success(let photos):
            return .just(photos)
        case .failure(let error):
            return .error(error)
        }
    }
}
