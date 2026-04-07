//
//  PhotoSearchViewModelTests.swift
//  PixSearchTests
//
//  Created by CHENG DING on 2026/04/07.
//

import XCTest
import RxSwift
import RxCocoa
@testable import PixSearch

final class PhotoSearchViewModelTests: XCTestCase {

    private var disposeBag: DisposeBag!
    private var mockRepository: MockPhotoRepository!
    private var viewModel: PhotoSearchViewModel!

    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        mockRepository = MockPhotoRepository()
        viewModel = PhotoSearchViewModel(photoRepository: mockRepository)
    }

    override func tearDown() {
        disposeBag = nil
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    /// 検索キーワードが空の場合、初期メッセージが出力されることを確認する
    func test_search_withEmptyKeyword_emitsInitialMessage() {
        let searchText = PublishSubject<String>()
        let searchButtonTapped = PublishSubject<Void>()
        let resetTrigger = PublishSubject<Void>()
        let itemSelected = PublishSubject<IndexPath>()

        let input = PhotoSearchViewModel.Input(
            searchText: searchText.asObservable(),
            searchButtonTapped: searchButtonTapped.asObservable(),
            resetTrigger: resetTrigger.asObservable(),
            itemSelected: itemSelected.asObservable()
        )

        let output = viewModel.transform(input: input)

        let expectation = expectation(description: "Initial message emitted")
        var receivedMessage: String?
        var didFulfill = false

        output.message
            .drive(onNext: { message in
                if message == PhotoSearchViewModel.Message.initial, !didFulfill {
                    didFulfill = true
                    receivedMessage = message
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        searchText.onNext("   ")
        searchButtonTapped.onNext(())

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedMessage, PhotoSearchViewModel.Message.initial)
    }

    /// 検索結果が存在する場合、画像一覧が出力されることを確認する
    func test_search_withPhotos_emitsLoadedPhotos() {
        let photos = [
            Photo(
                id: 1,
                photographerName: "Alice",
                thumbnailURL: URL(string: "https://example.com/thumb.jpg"),
                originalURL: URL(string: "https://example.com/original.jpg")
            )
        ]
        mockRepository.result = .success(photos)

        let searchText = PublishSubject<String>()
        let searchButtonTapped = PublishSubject<Void>()
        let resetTrigger = PublishSubject<Void>()
        let itemSelected = PublishSubject<IndexPath>()

        let input = PhotoSearchViewModel.Input(
            searchText: searchText.asObservable(),
            searchButtonTapped: searchButtonTapped.asObservable(),
            resetTrigger: resetTrigger.asObservable(),
            itemSelected: itemSelected.asObservable()
        )

        let output = viewModel.transform(input: input)

        let expectation = expectation(description: "Photos emitted")
        var receivedPhotos: [Photo] = []

        output.photos
            .drive(onNext: { photos in
                if !photos.isEmpty {
                    receivedPhotos = photos
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        searchText.onNext("nature")
        searchButtonTapped.onNext(())

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedPhotos.count, 1)
        XCTAssertEqual(receivedPhotos.first?.id, 1)
        XCTAssertEqual(receivedPhotos.first?.photographerName, "Alice")
    }

    /// 検索結果が0件の場合、emptyメッセージが出力されることを確認する
    func test_search_withEmptyResult_emitsEmptyMessage() {
        mockRepository.result = .success([])

        let searchText = PublishSubject<String>()
        let searchButtonTapped = PublishSubject<Void>()
        let resetTrigger = PublishSubject<Void>()
        let itemSelected = PublishSubject<IndexPath>()

        let input = PhotoSearchViewModel.Input(
            searchText: searchText.asObservable(),
            searchButtonTapped: searchButtonTapped.asObservable(),
            resetTrigger: resetTrigger.asObservable(),
            itemSelected: itemSelected.asObservable()
        )

        let output = viewModel.transform(input: input)

        let expectation = expectation(description: "Empty message emitted")
        var receivedMessage: String?

        output.message
            .drive(onNext: { message in
                if message == PhotoSearchViewModel.Message.empty {
                    receivedMessage = message
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        searchText.onNext("nature")
        searchButtonTapped.onNext(())

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedMessage, PhotoSearchViewModel.Message.empty)
    }

    /// 検索処理が失敗した場合、errorメッセージが出力されることを確認する
    func test_search_withFailure_emitsErrorMessage() {
        let error = NSError(domain: "TestError", code: 1)
        mockRepository.result = .failure(error)

        let searchText = PublishSubject<String>()
        let searchButtonTapped = PublishSubject<Void>()
        let resetTrigger = PublishSubject<Void>()
        let itemSelected = PublishSubject<IndexPath>()

        let input = PhotoSearchViewModel.Input(
            searchText: searchText.asObservable(),
            searchButtonTapped: searchButtonTapped.asObservable(),
            resetTrigger: resetTrigger.asObservable(),
            itemSelected: itemSelected.asObservable()
        )

        let output = viewModel.transform(input: input)

        let expectation = expectation(description: "Error message emitted")
        var receivedMessage: String?

        output.message
            .drive(onNext: { message in
                if message == PhotoSearchViewModel.Message.networkError {
                    receivedMessage = message
                    expectation.fulfill()
                }
            })
            .disposed(by: disposeBag)

        searchText.onNext("nature")
        searchButtonTapped.onNext(())

        waitForExpectations(timeout: 1.0)
        XCTAssertEqual(receivedMessage, PhotoSearchViewModel.Message.networkError)
    }
}
