//
//  PhotoRepositoryProtocol.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation
import RxSwift

protocol PhotoRepositoryProtocol {
    func searchPhotos(query: String) -> Single<[Photo]>
}
