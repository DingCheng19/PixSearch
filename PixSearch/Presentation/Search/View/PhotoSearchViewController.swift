//
//  PhotoSearchViewController.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import UIKit
import RxSwift
import RxCocoa

final class PhotoSearchViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate{

    private var displayedPhotos: [Photo] = []
    
    private let networkService = NetworkService()

    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search photos"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Please enter a keyword to search."
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = false
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("PhotoSearchViewController loaded")
        
        setupUI()
        setupLayout()
        setupCollectionView()
        setupSearchBar()
        updateEmptyState()
    }
}

private extension PhotoSearchViewController {

    func setupUI() {
        title = "PixFinder"
        view.backgroundColor = .systemBackground

        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyStateLabel)
        view.addSubview(loadingIndicator)
    }

    func setupLayout() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            PhotoCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier
        )
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
}

extension PhotoSearchViewController {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        searchBar.resignFirstResponder()

        // 検索キーワードが空の場合は初期状態に戻す
        guard !keyword.isEmpty else {
            displayedPhotos = []
            collectionView.reloadData()
            emptyStateLabel.text = "Please enter a keyword to search."
            updateEmptyState()
            print("検索キーワード未入力")
            return
        }

        updateLoadingState(isLoading: true)
        print("API検索開始: keyword=\(keyword)")

        networkService.searchPhotos(query: keyword) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let response = try JSONDecoder().decode(SearchPhotosResponseDTO.self, from: data)
                        self.displayedPhotos = response.photos.map { Photo(dto: $0) }

                        if self.displayedPhotos.isEmpty {
                            self.emptyStateLabel.text = "No photos found."
                        }

                        self.collectionView.reloadData()
                        self.updateLoadingState(isLoading: false)

                        print("API検索成功: keyword=\(keyword), count=\(self.displayedPhotos.count)")
                    } catch {
                        self.displayedPhotos = []
                        self.emptyStateLabel.text = "Failed to parse response."
                        self.collectionView.reloadData()
                        self.updateLoadingState(isLoading: false)

                        print("デコード失敗: \(error)")
                    }

                case .failure(let error):
                    self.displayedPhotos = []
                    self.emptyStateLabel.text = "Network error. Please try again."
                    self.collectionView.reloadData()
                    self.updateLoadingState(isLoading: false)

                    print("API検索失敗: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if keyword.isEmpty {
            displayedPhotos = []
            collectionView.reloadData()
            emptyStateLabel.text = "Please enter a keyword to search."
            updateEmptyState()

            print("検索条件クリア: 初期状態に戻す")
        }
    }
    
    func updateEmptyState() {
        let isEmpty = displayedPhotos.isEmpty
        emptyStateLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }
    
    // ローディング状態の表示を切り替える
    func updateLoadingState(isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            collectionView.isHidden = true
            emptyStateLabel.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            updateEmptyState()
        }
    }
}

extension PhotoSearchViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let photo = displayedPhotos[indexPath.item]
        cell.configure(with: photo)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 12
        let totalSpacing = spacing
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: width, height: width + 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = displayedPhotos[indexPath.item]
        print("写真選択: id=\(photo.id), photographer=\(photo.photographerName)")
        let detailViewController = PhotoDetailViewController(photo: photo)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
