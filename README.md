
# PixSearch

Pexels API を利用した写真検索アプリです。  
キーワード検索により写真一覧を取得し、選択した写真を詳細画面で閲覧することができます。  
本アプリは **UIKit + RxSwift + MVVM** を用いて実装しています。

---

## 📱 機能

- キーワードによる写真検索
- 検索結果の一覧表示（UICollectionView）
- 写真の詳細表示（全画面）
- 検索結果が0件の場合のメッセージ表示
- ネットワークエラー時のエラーハンドリング
- ローディングインジケーター表示

---

## 🛠 技術スタック

- Swift
- UIKit
- RxSwift / RxCocoa
- MVVM アーキテクチャ
- URLSession（API通信）
- XCTest（単体テスト）

---

## 🏗 アーキテクチャ

本アプリは MVVM パターンをベースに設計しています。

```text
Presentation/
└── Search/
    ├── View/
    └── ViewModel/

Domain/
└── Model/

Data/
├── Repository/
├── DTO/
└── Network/
```

---

## 💡 設計方針

- ViewController は UI とバインディングのみを担当
- ViewModel は状態管理とビジネスロジックを担当
- Repository は API 通信およびデータ変換を担当
- RxSwift によりリアクティブなデータフローを構築

---

## 🔄 RxSwift の利用

### ViewModel

Input / Output パターンを採用しています。

```swift
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
```
### ViewController
delegate を使用せず Rx によるバインディングを採用
UICollectionView のデータも Rx でバインド
UI の状態（表示・非表示）も Driver によって制御

### API

本アプリでは Pexels API を利用しています。

https://www.pexels.com/api/documentation/

### APIキーの設定方法
１、Pexels に登録して API Key を取得

２、以下の箇所に設定してください
```swift
private let apiKey = "YOUR_API_KEY"
```
## テスト
PhotoSearchViewModel に対して単体テストを実装しています。

テスト内容
空キーワード入力時の挙動
検索成功時のデータ取得
検索結果が0件の場合の挙動
APIエラー発生時のエラーハンドリング

## 実行方法
１、リポジトリを clone

２、Xcode でプロジェクトを開く

３、API Key を設定

４、ビルドして実行

## 実装におけるポイント
- MVVM + RxSwift による責務分離
- UI とロジックの疎結合化
- Repository パターンによるデータ取得の抽象化
- シンプルかつ拡張しやすい設計
