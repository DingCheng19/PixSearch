//
//  PhotoSearchViewModel.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation

final class PhotoSearchViewModel {

    // 画面に表示するメッセージを管理する
    enum Message {
        static let initial = "Please enter a keyword to search."
        static let empty = "No photos found."
        static let networkError = "Network error. Please try again."
        static let decodeError = "Failed to parse response."
    }

    private let photoRepository: PhotoRepositoryProtocol

    private(set) var state: PhotoSearchState = .initial(message: Message.initial)

    init(photoRepository: PhotoRepositoryProtocol = PhotoRepository()) {
        self.photoRepository = photoRepository
    }

    // 検索キーワードに応じて画像検索を実行する
    func search(keyword: String, completion: @escaping () -> Void) {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)

        // 検索キーワードが未入力の場合は初期状態に戻す
        guard !trimmedKeyword.isEmpty else {
            state = .initial(message: Message.initial)
            print("検索キーワード未入力")
            completion()
            return
        }

        state = .loading
        print("API検索開始: keyword=\(trimmedKeyword)")
        completion()

        photoRepository.searchPhotos(query: trimmedKeyword) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let photos):
                if photos.isEmpty {
                    self.state = .empty(message: Message.empty)
                    print("API検索成功: keyword=\(trimmedKeyword), count=0")
                } else {
                    self.state = .loaded(photos)
                    print("API検索成功: keyword=\(trimmedKeyword), count=\(photos.count)")
                }

            case .failure(let error):
                let nsError = error as NSError

                // ここでは仮にデコード系エラーを簡易判定する
                if nsError.domain == NSCocoaErrorDomain {
                    self.state = .error(message: Message.decodeError)
                    print("デコード失敗: \(error)")
                } else {
                    self.state = .error(message: Message.networkError)
                    print("API検索失敗: \(error.localizedDescription)")
                }
            }

            DispatchQueue.main.async {
                completion()
            }
        }
    }

    // 検索条件をクリアして初期状態に戻す
    func resetSearch(completion: @escaping () -> Void) {
        state = .initial(message: Message.initial)
        print("検索条件クリア: 初期状態に戻す")
        completion()
    }
}
