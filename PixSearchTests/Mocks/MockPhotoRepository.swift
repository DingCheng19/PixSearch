//
//  MockPhotoRepository.swift
//  PixSearchTests
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation
@testable import PixSearch

final class MockPhotoRepository: PhotoRepositoryProtocol {

    var result: Result<[Photo], Error> = .success([])

    func searchPhotos(query: String, completion: @escaping (Result<[Photo], Error>) -> Void) {
        completion(result)
    }
}
