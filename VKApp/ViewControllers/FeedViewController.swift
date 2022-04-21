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
   
    enum CellType: Int {
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
        
        tableView.sectionHeaderTopPadding = 16.0
        tableView.register(for: FeedFooterView.self)
        loadingDotes()
        
        feedService.getFeeds {
            self.feedNews = self.feedService.feedNews
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.animatedView.isHidden = true
            }
        }
    }
    
    // MARK: - Animation
    
    func loadingDotes() {
        UIView.animate(
            withDuration: shortDuration,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) { [self] in
            loadingViews[0].alpha = 1
        }
        UIView.animate(
            withDuration: shortDuration,
            delay: 0.2,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) { [self] in
            loadingViews[1].alpha = 1
        }
        UIView.animate(
            withDuration: shortDuration,
            delay: 0.4,
            options: [.repeat, .autoreverse, .curveEaseInOut]
        ) { [self] in
            loadingViews[2].alpha = 1
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        VKWVLoginViewController.keychain.delete("accessToken")
        VKWVLoginViewController.keychain.delete("userID")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: "VKWVLoginViewController")
                as? VKWVLoginViewController else { return }
        view.loadView()
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords( ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach {
                if $0.displayName.contains("vk") {
                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [$0]) {
                        guard
                            let url = view.urlComponents.url
                        else { return }
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
        return 64
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        let headerView: ImageCell = UIView.fromNib()
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        let currentFeed = feedNews[section]
        if let user = currentFeed.user {
            headerView.configureFeedCell(
                label: user.userName,
                pictureURL: user.userPhotoURLString,
                color: user.codeColor,
                date: currentFeed.date
            )
        } else if let group = currentFeed.group {
            headerView.configureFeedCell(
                label: group.title,
                pictureURL: group.groupPictureURL,
                color: group.codeColor,
                date: currentFeed.date
            )
        }
        return view
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer: FeedFooterView = tableView.dequeueReusableHeaderFooterView()
        footer.configurateFooter(feed: feedNews[section]) {
            var sharedItem = [Any]()
            var array = [String]()
            if let message = self.feedNews[section].messageText {
                array.append(message)
            }
            sharedItem = !self.feedNews[section].photos.isEmpty
            ? self.feedNews[section].photos.compactMap(\.imageURLString)
            : array

            let activityView = UIActivityViewController(activityItems: sharedItem, applicationActivities: nil)
            self.present(activityView, animated: true, completion: nil)
        }
        return footer
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
