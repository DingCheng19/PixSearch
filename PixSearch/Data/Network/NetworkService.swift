//
//  NetworkService.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation

final class NetworkService {

    func searchPhotos(query: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard var components = URLComponents(string: "\(APIConfig.baseURL)/search") else {
            return
        }

        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: "20"),
            URLQueryItem(name: "page", value: "1")
        ]

        guard let url = components.url else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(APIConfig.apiKey, forHTTPHeaderField: "Authorization")

        print("API検索開始: \(url.absoluteString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("API検索失敗: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let data else {
                completion(.failure(NSError(domain: "NetworkService", code: -1)))
                return
            }

            print("API検索成功")
            completion(.success(data))
        }.resume()
    }
}
