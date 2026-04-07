//
//  PhotoRepositoryProtocol.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation

protocol PhotoRepositoryProtocol {
    func searchPhotos(query: String, completion: @escaping (Result<[Photo], Error>) -> Void)
}
