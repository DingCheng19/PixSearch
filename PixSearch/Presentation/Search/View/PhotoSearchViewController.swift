//
//  PhotoSearchViewController.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import UIKit

final class PhotoSearchViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate{
    
    private var displayedPhotos: [Photo] = []
    private let viewModel = PhotoSearchViewModel()
    
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
        applyState()
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
        let keyword = searchBar.text ?? ""
        searchBar.resignFirstResponder()

        viewModel.search(keyword: keyword) { [weak self] in
            self?.applyState()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if keyword.isEmpty {
            viewModel.resetSearch { [weak self] in
                self?.applyState()
            }
        }
    }
    
    // ViewModelの状態に応じて画面表示を更新する
    func applyState() {
        switch viewModel.state {
        case .initial(let message):
            displayedPhotos = []
            emptyStateLabel.text = message
            collectionView.reloadData()
            updateEmptyState()

        case .loading:
            updateLoadingState(isLoading: true)

        case .loaded(let photos):
            displayedPhotos = photos
            collectionView.reloadData()
            updateLoadingState(isLoading: false)

        case .empty(let message):
            displayedPhotos = []
            emptyStateLabel.text = message
            collectionView.reloadData()
            updateLoadingState(isLoading: false)

        case .error(let message):
            displayedPhotos = []
            emptyStateLabel.text = message
            collectionView.reloadData()
            updateLoadingState(isLoading: false)
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
