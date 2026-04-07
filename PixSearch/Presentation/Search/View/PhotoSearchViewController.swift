//
//  PhotoSearchViewController.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import UIKit
import RxSwift
import RxCocoa

final class PhotoSearchViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private let samplePhotos: [Photo] = [
        Photo(
            id: 1,
            photographerName: "Alice",
            thumbnailURL: URL(string: "https://images.pexels.com/photos/414612/pexels-photo-414612.jpeg"),
            originalURL: URL(string: "https://images.pexels.com/photos/414612/pexels-photo-414612.jpeg")
        ),
        Photo(
            id: 2,
            photographerName: "Bob",
            thumbnailURL: URL(string: "https://images.pexels.com/photos/34950/pexels-photo.jpg"),
            originalURL: URL(string: "https://images.pexels.com/photos/34950/pexels-photo.jpg")
        ),
        Photo(
            id: 3,
            photographerName: "Charlie",
            thumbnailURL: URL(string: "https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg"),
            originalURL: URL(string: "https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg")
        ),
        Photo(
            id: 4,
            photographerName: "David",
            thumbnailURL: URL(string: "https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg"),
            originalURL: URL(string: "https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg")
        )
    ]

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

    override func viewDidLoad() {
        super.viewDidLoad()
        print("PhotoSearchViewController loaded")
        setupUI()
        setupLayout()
        setupCollectionView()
    }
}

private extension PhotoSearchViewController {

    func setupUI() {
        title = "PixFinder"
        view.backgroundColor = .systemBackground

        view.addSubview(searchBar)
        view.addSubview(collectionView)
    }

    func setupLayout() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
}

extension PhotoSearchViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return samplePhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionViewCell.identifier,
            for: indexPath
        ) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let photo = samplePhotos[indexPath.item]
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
        let photo = samplePhotos[indexPath.item]
        let detailViewController = PhotoDetailViewController(photo: photo)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
