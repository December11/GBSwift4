//
//  FeedViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.01.2022.
//

import UIKit
import WebKit
import RealmSwift

final class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    private let loadDuration = 2.0
    private let shortDuration = 0.5
    var feedNews = [Feed]()

   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var loadingViews: [UIView]!
    @IBOutlet weak var animatedView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.animatedView.isHidden = false
        loadingDotes()
        do {
            try UsersService.instance.updateData()
            try GroupsService.instance.updateData()
        } catch {
            print(error)
        }
        
        tableView.sectionHeaderTopPadding = 16.0
        
        tableView.register(
            UINib(nibName: "FeedFooterView", bundle: nil),
            forHeaderFooterViewReuseIdentifier: "feedFooterView"
        )

        fetchFeedsByJSON()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isMessageEmpty = feedNews[section].messageText?.isEmpty
        let isPhotosEmpty = feedNews[section].photos.isEmpty
        switch (isMessageEmpty, isPhotosEmpty) {
        case (true, false), (false, true):
            return 1
        case (false, false):
            return 2
        default:
            return 1
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        feedNews.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UITableViewHeaderFooterView()
        let headerView: ImageCell = UIView.fromNib()
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let currentFeed = feedNews[section]
        if let user = currentFeed.user {
            headerView.configureFeedCell(
                label: user.userName,
                pictureURL: user.userPhotoURLString,
                color: user.codeColor,
                date: currentFeed.date
            )
        } else {
            headerView.configureFeedCell(
                label: currentFeed.group?.title,
                pictureURL: currentFeed.group?.groupPictureURL,
                color: currentFeed.group?.codeColor,
                date: currentFeed.date
            )
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard
            let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "feedFooterView") as? FeedFooterView
        else { return UIView() }
        
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentFeed = feedNews[indexPath.section]
        
        switch (indexPath.row) {
        case 0:
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "feedCell",
                    for: indexPath
                ) as? FeedCell
            else { return UITableViewCell() }
            
            cell.configureFeedCell(feed: currentFeed)
            return cell
            
        case 1:
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: "feedImagesCell",
                    for: indexPath
                ) as? FeedImagesCell
            else { return UITableViewCell() }
            
            cell.configureFeedCell(feed: currentFeed)
            return cell
            
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - Private methods
    private func fetchFeedsByJSON() {
        
        let feedService = NetworkService<FeedDTO>()
        
        feedService.path = "/method/newsfeed.get"
        feedService.queryItems = [
            URLQueryItem(name: "filters", value: "post"),
            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
            URLQueryItem(name: "v", value: "5.131")
        ]
        feedService.fetch { [weak self] feedDTOObjects in
            switch feedDTOObjects {
            case .failure(let error):
                print(error)
            case .success(let feedsDTO):
                guard let self = self else { return }
                DispatchQueue.main.async {
                self.feedNews = feedsDTO.map { feed in
                    
                    let photosURLs = self.loadPhotosFromFeed(feed)
                    
                    if feed.sourceID > 0,
                       let user = self.loadUserByID(feed.sourceID) {
                        return Feed(
                            user: user,
                            messageText: feed.text,
                            photos: photosURLs,
                            date: Date(timeIntervalSince1970: feed.date),
                            likesCount: feed.likes.count,
                            commentsCount: feed.comments.count,
                            viewsCount: feed.views?.count ?? 0)
                    } else {
                        if let group = self.loadGroupByID(feed.sourceID) {
                            return Feed(
                                group: group,
                                messageText: feed.text,
                                photos: photosURLs,
                                date: Date(timeIntervalSince1970: feed.date),
                                likesCount: feed.likes.count,
                                commentsCount: feed.comments.count,
                                viewsCount: feed.views?.count ?? 0)
                        }
                    }
                    return Feed(
                        user: User(id: 0, firstName: "No", secondName: "username", userPhotoURLString: nil),
                        messageText: feed.text,
                        photos: photosURLs,
                        date: Date(timeIntervalSince1970: feed.date),
                        likesCount: feed.likes.count,
                        commentsCount: feed.comments.count,
                        viewsCount: feed.views?.count ?? 0
                    )
                }
                self.feedNews = self.feedNews.filter{ $0.messageText != "" }
                    self.tableView.reloadData()
                    self.animatedView.isHidden = true
                }
            }
        }
    }
    
    private func loadUserByID(_ id: Int) -> User? {
        do {
            print("7")
            let realmUsers: [RealmUser] = try RealmService.load(typeOf: RealmUser.self)
            print("8")
            if let user = realmUsers.filter({ $0.id == id }).first {
                return User(
                    id: user.id,
                    firstName: user.firstName,
                    secondName: user.secondName,
                    userPhotoURLString: user.userPhotoURLString
                )
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    private func loadGroupByID(_ id: Int) -> Group? {
        do {
            print("9")
            let realmGroups: [RealmGroup] = try RealmService.load(typeOf: RealmGroup.self)
            print("10")
            if let group = realmGroups.filter({ $0.id == -id }).first {
                return Group(id: group.id, title: group.title, imageURL: group.groupPhotoURL)
            } else {
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    //MARK: - Private Realm methods
    private func updateFeeds(_ realmFeeds: [RealmFeed]) {
        feedNews = realmFeeds.map({ realmFeed in
            if let id = realmFeed.sourceID,
               id > 0,
               let user = self.loadUserByID(id) {
                return Feed(user: user,
                            messageText: realmFeed.text,
                            photos: realmFeed.photoURLs.map { Photo(imageURLString: $0) },
                            date: realmFeed.date,
                            likesCount: realmFeed.likeCount,
                            commentsCount: realmFeed.commentCount,
                            viewsCount: realmFeed.viewCount)
            } else if
                let id = realmFeed.sourceID,
                let group = self.loadGroupByID(id) {
                return Feed(group: group,
                            messageText: realmFeed.text,
                            photos: realmFeed.photoURLs.map { Photo(imageURLString: $0) },
                            date: realmFeed.date,
                            likesCount: realmFeed.likeCount,
                            commentsCount: realmFeed.commentCount,
                            viewsCount: realmFeed.viewCount)
            }
            return Feed(group: Group(id: 0, title: "No title", imageURL: nil),
                        messageText: realmFeed.text,
                        photos: realmFeed.photoURLs.map { Photo(imageURLString: $0) },
                        date: realmFeed.date,
                        likesCount: realmFeed.likeCount,
                        commentsCount: realmFeed.commentCount,
                        viewsCount: realmFeed.viewCount)
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func loadPhotosFromFeed(_ feed: FeedDTO) -> [Photo]? {
        guard let images = feed.photosURLs else { return nil }
        let photos = images.compactMap { $0.photo }
        let photoSizes = photos.map { $0.photos }
        return photoSizes.map { Photo(imageURLString: $0.last?.url) }
    }
    
    
    //MARK: - Animation
    func loadingDotes() {
        UIView.animate(withDuration: shortDuration, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) { [self] in
            loadingViews[0].alpha = 1
        }
        UIView.animate(withDuration: shortDuration, delay: 0.2, options: [.repeat, .autoreverse, .curveEaseInOut]) { [self] in
            loadingViews[1].alpha = 1
        }
        UIView.animate(withDuration: shortDuration, delay: 0.4, options: [.repeat, .autoreverse, .curveEaseInOut]) { [self] in
            loadingViews[2].alpha = 1
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        SessionStorage.shared.token = ""
        SessionStorage.shared.userId = 0
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: "VKWVLoginViewController") as? VKWVLoginViewController else { return }
        view.loadView()
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords( ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach {
                if $0.displayName.contains("vk") {
                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [$0]) {
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
