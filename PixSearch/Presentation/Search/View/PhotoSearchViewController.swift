//
//  PhotoSearchViewController.swift
//  PixSearch
//
//  Created by CHENG DING on 2026/04/07.
//

import UIKit
import RxSwift
import RxCocoa

final class PhotoSearchViewController: UIViewController {
    
    private let viewModel: PhotoSearchViewModel
    private let disposeBag = DisposeBag()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search photos"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            PhotoCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier
        )
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
    
    init(viewModel: PhotoSearchViewModel = PhotoSearchViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PhotoSearchViewController loaded")
        
        setupUI()
        setupLayout()
        setupBindings()
    }
}

private extension PhotoSearchViewController {
    
    // 画面上のUI部品を追加する
    func setupUI() {
        title = "PixFinder"
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptyStateLabel)
        view.addSubview(loadingIndicator)
    }
    
    // Auto Layoutで各UI部品の位置を設定する
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
    
    func setupBindings() {
        let resetTrigger = searchBar.rx.text.orEmpty
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .distinctUntilChanged()
            .filter { $0 }
            .map { _ in () }
            .asObservable()
        
        let input = PhotoSearchViewModel.Input(
            searchText: searchBar.rx.text.orEmpty.asObservable(),
            searchButtonTapped: searchBar.rx.searchButtonClicked.asObservable(),
            resetTrigger: resetTrigger,
            itemSelected: collectionView.rx.itemSelected.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        bindPhotos(output.photos)
        bindLoading(output.isLoading)
        bindMessage(output.message)
        bindSelection(output.selectedPhoto)
        
        searchBar.rx.searchButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func bindPhotos(_ photos: Driver<[Photo]>) {
        photos
            .drive(
                collectionView.rx.items(
                    cellIdentifier: PhotoCollectionViewCell.identifier,
                    cellType: PhotoCollectionViewCell.self
                )
            ) { _, photo, cell in
                cell.configure(with: photo)
            }
            .disposed(by: disposeBag)
        
        photos
            .map { !$0.isEmpty }
            .drive(onNext: { [weak self] hasPhotos in
                guard let self = self else { return }
                self.collectionView.isHidden = !hasPhotos
            })
            .disposed(by: disposeBag)
    }
    
    func bindLoading(_ isLoading: Driver<Bool>) {
        isLoading
            .drive(onNext: { [weak self] loading in
                guard let self = self else { return }
                
                if loading {
                    self.loadingIndicator.startAnimating()
                    self.collectionView.isHidden = true
                    self.emptyStateLabel.isHidden = true
                } else {
                    self.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindMessage(_ message: Driver<String?>) {
        message
            .drive(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.emptyStateLabel.text = message
                let shouldShowMessage = !(message?.isEmpty ?? true)
                self.emptyStateLabel.isHidden = !shouldShowMessage
            })
            .disposed(by: disposeBag)
    }
    
    func bindSelection(_ selectedPhoto: Signal<Photo>) {
        selectedPhoto
            .emit(onNext: { [weak self] photo in
                guard let self = self else { return }
                print("写真選択: id=\(photo.id), photographer=\(photo.photographerName)")
                let detailViewController = PhotoDetailViewController(photo: photo)
                self.navigationController?.pushViewController(detailViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}

extension PhotoSearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 12
        let totalSpacing = spacing
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: width, height: width + 24)
    }
}
