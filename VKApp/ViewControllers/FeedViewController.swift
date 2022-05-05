//
//  FeedViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.01.2022.
//

import KeychainSwift
import UIKit
import WebKit

final class FeedViewController: UIViewController {
    private enum CellType: Int {
        case messageText = 0, images
    }
    
    private let loadDuration = 2.0
    private let shortDuration = 0.5
    private let feedService = FeedsService.instance
    private var lastFeedDateString: String?
    fileprivate var nextFrom = ""
    fileprivate var isLoading = false
    fileprivate var feedNews = [Feed]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var loadingViews: [UIView]!
    @IBOutlet weak var animatedView: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.animatedView.isHidden = false
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        
        tableView.sectionHeaderTopPadding = 16.0
        tableView.register(for: FeedFooterView.self)
        loadingDotes()
        
        if self.feedNews.count == 0 {
            self.feedNews = self.getDemoData()
            print("## Oh, I don't receive any data, so I get you my demo data")
            self.tableView.reloadData()
            self.animatedView.isHidden = true
        }
        
        feedService.getFeeds { [weak self] in
            guard let feedNews = self?.feedService.feedNews else { return }
            self?.feedNews = feedNews
            self?.nextFrom = self?.feedService.nextFrom ?? ""
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.animatedView.isHidden = true
            }
        }
        
        setupRefreshControl()
    }
    
    // MARK: - Pull-to-refresh
    
    private func setupRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refreshNews), for: .valueChanged)
    }
    
    @objc private func refreshNews() {
        tableView.refreshControl?.beginRefreshing()
        if let date1 = feedNews.first?.date.timeIntervalSince1970 {
            lastFeedDateString = (date1+1).description
        }
        guard let date = lastFeedDateString else {
            self.tableView.refreshControl?.endRefreshing()
            return
        }
        feedService.getFeeds(by: date, nextFrom: nextFrom) { [weak self] feeds in
            guard let self = self else { return }
            var newFeeds = feeds
            if feeds.count == 0 {
                newFeeds = self.getMoreNewData()
            }
            self.tableView.refreshControl?.endRefreshing()
            guard newFeeds.count > 0 else { return }
            self.feedNews.insert(contentsOf: newFeeds, at: 0)
            self.tableView.reloadData()
            self.lastFeedDateString = self.feedNews.first?.date.timeIntervalSince1970.description
        }
    }
    
    // MARK: - Animation
    
    func loadingDotes() {
        UIView.animate(
            withDuration: shortDuration,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) { [weak self] in
            self?.loadingViews[0].alpha = 1
        }
        UIView.animate(
            withDuration: shortDuration,
            delay: 0.2,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) { [weak self] in
            self?.loadingViews[1].alpha = 1
        }
        UIView.animate(
            withDuration: shortDuration,
            delay: 0.4,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) { [weak self] in
            self?.loadingViews[2].alpha = 1
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        VKWVLoginViewController.logout()
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 2:
            let tableViewWidth = tableView.bounds.width
            let currentFeed = feedNews[indexPath.section]
            // TODO: найти aspectRatio неск. фоток
            if currentFeed.photos.count == 1 {
                let cellHeight = tableViewWidth * (currentFeed.photos.first?.aspectRatio ?? 1.0)
                return cellHeight
            } else {
                return 414.0
            }
        default:
            return UITableView.automaticDimension
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        64
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        44
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let currentFeed = feedNews[section]
        let headerView = FeedHeaderView()
        headerView.setupConstraints()
        return headerView.configurateHeader(feed: currentFeed)
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer: FeedFooterView = tableView.dequeueReusableHeaderFooterView()
        footer.configurateFooter(feed: feedNews[section]) { [weak self] in
            guard let feed = self?.feedNews[section] else { return }
            self?.callActivityView(for: feed)
        }
        return footer
    }
    
    private func callActivityView(for feed: Feed) {
        var sharedItem = [Any]()
        var array = [String]()
        if let message = feed.messageText {
            array.append(message)
        }
        sharedItem = !feed.photos.isEmpty
        ? feed.photos.compactMap { $0.imageURLString }
        : array
        
        let activityView = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
        self.present(activityView, animated: true, completion: nil)
    }
    
    private func getMoreNewData() -> [Feed] {
        return [
            Feed(
                group: Group(id: 0, title: "Demo group + \(String(Int.random(in: 0...10)))", imageURL: nil),
                messageText: String().rand,
                photos: nil,
                date: Date())
        ]
    }
    
    private func getDemoData() -> [Feed] {
        let demoFeeds = [
            Feed(
                group: Group(id: 0, title: "Demo group 1", imageURL: nil),
                messageText: """
Some long text: newsfeed.get: Возвращает данные, необходимые для показа списка новостей для текущего пользователя.
filters - string: Перечисленные через запятую названия списков новостей, которые необходимо получить.
В данный момент поддерживаются следующие списки новостей:
• post — новые записи со стен;
• photo — новые фотографии;
• photo_tag — новые отметки на фотографиях;
• wall_photo — новые фотографии на стенах;
• friend — новые друзья;
• note — новые заметки;
• audio — записи сообществ и друзей, содержащие аудиозаписи, а также новые аудиозаписи, добавленные ими;
• video — новые видеозаписи.
Если параметр не задан, то будут получены все возможные списки новостей.
""",
                photos: nil,
                date: Date()
            ),
            Feed(
                group: Group(id: 1, title: "Demo group 2", imageURL: nil),
                messageText: """
                1. short message: 0123456789,
                2. short message: 0123456789,
                3. short message: 0123456789,
                4. short message: 0123456789
""",
                photos: nil,
                date: Date()
            ),
            Feed(
                group: Group(id: 3, title: "Demo group 3", imageURL: nil),
                messageText: "Oh, I'm a really short message <3",
                photos: nil,
                date: Date()
            )
        ]
        return demoFeeds
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isMessageEmpty = feedNews[section].messageText?.isEmpty
        let isPhotosEmpty = feedNews[section].photos.isEmpty
        switch (isMessageEmpty, isPhotosEmpty) {
        case (false, false):
            return 2
        default:
            return 1
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        feedNews.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentFeed = feedNews[indexPath.section]
        switch indexPath.row {
        case CellType.messageText.rawValue:
            let cell: FeedCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configureFeedCell(feed: currentFeed, handler: {
                self.tableView.reloadData()
            })
            return cell
        case CellType.images.rawValue:
            let cell: FeedImagesCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configureFeedCell(feed: currentFeed)
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let maxSections = indexPaths.map({ $0.section }).max() else {
            print("## Error. No max sections")
            return
        }
        if maxSections > feedNews.count - 3 {
            if !isLoading {
                isLoading = true
                if let date = self.feedNews.last?.date.timeIntervalSince1970.description {
                    feedService.getFeeds(by: date, nextFrom: nextFrom) { [weak self] feeds in
                        guard let self = self else { return }
                        var newFeeds = feeds
                        if feeds.count == 0 {
                            newFeeds = self.getMoreNewData()
                        }
                        self.feedNews.append(contentsOf: newFeeds)
                        self.tableView.reloadData()
                        self.isLoading = false
                    }
                }
            }
        }
    }
}
