//
//  PhotoSearchViewModelTests.swift
//  PixSearchTests
//
//  Created by CHENG DING on 2026/04/07.
//

import XCTest
@testable import PixSearch

final class PhotoSearchViewModelTests: XCTestCase {

    private var mockRepository: MockPhotoRepository!
    private var viewModel: PhotoSearchViewModel!

    override func setUp() {
        super.setUp()
        mockRepository = MockPhotoRepository()
        viewModel = PhotoSearchViewModel(photoRepository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Test Cases

    /// 検索キーワードが空の場合、状態が初期状態（.initial）になることを確認する
    func test_search_withEmptyKeyword_setsInitialState() {
        let expectation = expectation(description: "Completion called")

        // 空白のみのキーワードを指定
        viewModel.search(keyword: "   ") {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        // stateが.initialになっていることを検証
        switch viewModel.state {
        case .initial(let message):
            XCTAssertEqual(message, PhotoSearchViewModel.Message.initial)
        default:
            XCTFail("Expected state to be .initial")
        }
    }

    /// 検索結果が存在する場合、状態が.loadedになり、データが正しく設定されることを確認する
    func test_search_withPhotos_setsLoadedState() {
        let photos = [
            Photo(
                id: 1,
                photographerName: "Alice",
                thumbnailURL: URL(string: "https://example.com/thumb.jpg"),
                originalURL: URL(string: "https://example.com/original.jpg")
            )
        ]

        // モックの戻り値を設定（成功＋データあり）
        mockRepository.result = .success(photos)

        let expectation = expectation(description: "Completion called")

        viewModel.search(keyword: "nature") {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        // stateが.loadedであり、データが一致していることを検証
        switch viewModel.state {
        case .loaded(let loadedPhotos):
            XCTAssertEqual(loadedPhotos.count, 1)
            XCTAssertEqual(loadedPhotos.first?.id, 1)
            XCTAssertEqual(loadedPhotos.first?.photographerName, "Alice")
        default:
            XCTFail("Expected state to be .loaded")
        }
    }

    /// 検索結果が0件の場合、状態が.emptyになることを確認する
    func test_search_withEmptyResult_setsEmptyState() {
        // モックの戻り値を設定（成功＋空配列）
        mockRepository.result = .success([])

        let expectation = expectation(description: "Completion called")

        viewModel.search(keyword: "nature") {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        // stateが.emptyになっていることを検証
        switch viewModel.state {
        case .empty(let message):
            XCTAssertEqual(message, PhotoSearchViewModel.Message.empty)
        default:
            XCTFail("Expected state to be .empty")
        }
    }

    /// 検索処理が失敗した場合、状態が.errorになることを確認する
    func test_search_withFailure_setsErrorState() {
        let error = NSError(domain: "TestError", code: 1)

        // モックの戻り値を設定（失敗）
        mockRepository.result = .failure(error)

        let expectation = expectation(description: "Completion called")

        viewModel.search(keyword: "nature") {
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)

        // stateが.errorになっていることを検証
        switch viewModel.state {
        case .error(let message):
            XCTAssertEqual(message, PhotoSearchViewModel.Message.networkError)
        default:
            XCTFail("Expected state to be .error")
        }
    }
}
