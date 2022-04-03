//
//  FeedService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 03.04.2022.
//

import RealmSwift
import UIKit

final class FeedService {
    static let instance = FeedService()
    private init() { }
//    private func fetchFeedsByJSON() {
//
//        let feedService = NetworkService<FeedDTO>()
//
//        feedService.path = "/method/newsfeed.get"
//        feedService.queryItems = [
//            URLQueryItem(name: "filters", value: "post"),
//            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
//            URLQueryItem(name: "v", value: "5.131")
//        ]
//        feedService.fetch { [weak self] feedDTOObjects in
//            switch feedDTOObjects {
//            case .failure(let error):
//                print(error)
//            case .success(let feedsDTO):
//                guard let self = self else { return }
//                DispatchQueue.main.async {
//                self.feedNews = feedsDTO.map { feed in
//
//                    let photosURLs = self.loadPhotosFromFeed(feed)
//
//                    if feed.sourceID > 0,
//                       let user = self.loadUserByID(feed.sourceID) {
//                        return Feed(
//                            user: user,
//                            messageText: feed.text,
//                            photos: photosURLs,
//                            date: Date(timeIntervalSince1970: feed.date),
//                            likesCount: feed.likes.count,
//                            commentsCount: feed.comments.count,
//                            viewsCount: feed.views?.count ?? 0)
//                    } else {
//                        if let group = self.loadGroupByID(feed.sourceID) {
//                            return Feed(
//                                group: group,
//                                messageText: feed.text,
//                                photos: photosURLs,
//                                date: Date(timeIntervalSince1970: feed.date),
//                                likesCount: feed.likes.count,
//                                commentsCount: feed.comments.count,
//                                viewsCount: feed.views?.count ?? 0)
//                        }
//                    }
//                    return Feed(
//                        user: User(id: 0, firstName: "No", secondName: "username", userPhotoURLString: nil),
//                        messageText: feed.text,
//                        photos: photosURLs,
//                        date: Date(timeIntervalSince1970: feed.date),
//                        likesCount: feed.likes.count,
//                        commentsCount: feed.comments.count,
//                        viewsCount: feed.views?.count ?? 0
//                    )
//                }
//                self.feedNews = self.feedNews.filter { $0.messageText != "" }
//                    self.tableView.reloadData()
//                    self.animatedView.isHidden = true
//                }
//            }
//        }
//    }
//
}
