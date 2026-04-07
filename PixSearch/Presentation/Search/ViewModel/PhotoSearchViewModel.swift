//
//  PhotoSearchViewModel.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import Foundation
import RxSwift
import RxCocoa

final class PhotoSearchViewModel {

    enum Message {
        static let initial = "Please enter a keyword to search."
        static let empty = "No photos found."
        static let networkError = "Network error. Please try again."
        static let decodeError = "Failed to parse response."
    }

    struct Input {
        let searchText: Observable<String>
        let searchButtonTapped: Observable<Void>
        let resetTrigger: Observable<Void>
        let itemSelected: Observable<IndexPath>
    }

    struct Output {
        let photos: Driver<[Photo]>
        let isLoading: Driver<Bool>
        let message: Driver<String?>
        let selectedPhoto: Signal<Photo>
    }

    private let photoRepository: PhotoRepositoryProtocol
    private let disposeBag = DisposeBag()

    init(photoRepository: PhotoRepositoryProtocol = PhotoRepository()) {
        self.photoRepository = photoRepository
    }

    func transform(input: Input) -> Output {
        let photosRelay = BehaviorRelay<[Photo]>(value: [])
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let messageRelay = BehaviorRelay<String?>(value: Message.initial)

        let trimmedKeyword = input.searchText
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        input.resetTrigger
            .subscribe(onNext: {
                photosRelay.accept([])
                messageRelay.accept(Message.initial)
                loadingRelay.accept(false)
                print("検索条件クリア: 初期状態に戻す")
            })
            .disposed(by: disposeBag)

        input.searchButtonTapped
            .withLatestFrom(trimmedKeyword)
            .subscribe(onNext: { [weak self] keyword in
                guard let self = self else { return }

                guard !keyword.isEmpty else {
                    photosRelay.accept([])
                    messageRelay.accept(Message.initial)
                    loadingRelay.accept(false)
                    print("検索キーワード未入力")
                    return
                }

                loadingRelay.accept(true)
                messageRelay.accept(nil)
                print("API検索開始: keyword=\(keyword)")

                self.photoRepository.searchPhotos(query: keyword)
                    .observe(on: MainScheduler.instance)
                    .subscribe(
                        onSuccess: { photos in
                            loadingRelay.accept(false)
                            photosRelay.accept(photos)

                            if photos.isEmpty {
                                messageRelay.accept(Message.empty)
                                print("API検索成功: keyword=\(keyword), count=0")
                            } else {
                                messageRelay.accept(nil)
                                print("API検索成功: keyword=\(keyword), count=\(photos.count)")
                            }
                        },
                        onFailure: { error in
                            loadingRelay.accept(false)
                            photosRelay.accept([])

                            let nsError = error as NSError
                            if nsError.domain == NSCocoaErrorDomain {
                                messageRelay.accept(Message.decodeError)
                                print("デコード失敗: \(error)")
                            } else {
                                messageRelay.accept(Message.networkError)
                                print("API検索失敗: \(error.localizedDescription)")
                            }
                        }
                    )
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)

        let selectedPhoto = input.itemSelected
            .withLatestFrom(photosRelay.asObservable()) { indexPath, photos -> Photo? in
                guard indexPath.item < photos.count else { return nil }
                return photos[indexPath.item]
            }
            .compactMap { $0 }
            .asSignal(onErrorSignalWith: .empty())

        return Output(
            photos: photosRelay.asDriver(),
            isLoading: loadingRelay.asDriver(),
            message: messageRelay.asDriver(),
            selectedPhoto: selectedPhoto
        )
    }
}
