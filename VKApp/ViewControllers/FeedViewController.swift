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
        
        tableView.sectionHeaderTopPadding = 16.0
        tableView.register(for: FeedFooterView.self)
        loadingDotes()
        
        feedService.getFeeds { [weak self] in
            guard let feedNews = self?.feedService.feedNews else { return }
            self?.feedNews = feedNews
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.animatedView.isHidden = true
            }
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
        AuthService.shared.deleteAuthData()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: "VKWVLoginViewController")
                as? VKWVLoginViewController else { return }
        view.loadView()
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords( ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach {
                if $0.displayName.contains("vk") {
                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [$0]) {
                        var urlComponents: URLComponents {
                            var components = URLComponents()
                            components.scheme = "https"
                            components.host = "oauth.vk.com"
                            components.path = "/authorize"
                            components.queryItems = [
                                URLQueryItem(name: "client_id", value: "8077898"),
                                URLQueryItem(name: "display", value: "mobile"),
                                URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
                                URLQueryItem(name: "scope", value: "336918"),
                                URLQueryItem(name: "response_type", value: "token"),
                                URLQueryItem(name: "v", value: "5.131"),
                                URLQueryItem(name: "revoke", value: "1")
                            ]
                            return components
                        }

                        guard
                            let url = view.urlComponents.url
                        else { return }

                        view.webView.load(URLRequest(url: url))
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
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
            cell.configureFeedCell(feed: currentFeed)
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
