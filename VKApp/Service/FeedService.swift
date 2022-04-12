//
//  FeedService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 05.04.2022.
//

import RealmSwift
import UIKit

final class FeedsService {
    static let instance = FeedsService()
    
    var feedNews = [Feed]()
    
    private var groupService = GroupsService.instance
    private var userService = UsersService.instance
    private var isDataUpdated = false
    
    private init() {}
        
    // MARK: - Methods
    func getFeeds(completion: @escaping () -> Void) {
        fetchFromJSON { feeds in
            self.feedNews = feeds.filter { $0.messageText != "" }
            completion()
        }
    }
    
    // MARK: - Private methods
    private func fetchFromJSON(completion: @escaping ([Feed]) -> Void) {
        let dispatchGroup = DispatchGroup()
        let feedService = NetworkService<FeedDTO>()
        feedService.path = "/method/newsfeed.get"
        feedService.queryItems = [
            URLQueryItem(name: "filters", value: "post"),
            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
            URLQueryItem(name: "v", value: "5.131")
        ]
        userService.loadDataIfNeeded()
        groupService.loadDataIfNeeded()
        feedService.fetch { [weak self] feedsDTO in
            switch feedsDTO {
            case .failure(let error):
                print("## Error. Can't load groups from JSON", error)
            case .success(let feedsDTO):
                guard let self = self else { return }
                let feeds = feedsDTO.map { feed -> Feed in
                    let isFeedFromUser = feed.sourceID >= 0
                    if isFeedFromUser {
                        return self.configurateUserFeed(feed)
                    } else {
                        return self.configurateGroupFeed(feed)
                    }
                }
                dispatchGroup.notify(queue: DispatchQueue.main) {
                    completion(feeds)
                }
            }
        }
    }
 
    private func configurateUserFeed(_ feed: FeedDTO) -> Feed {
        let photosURLs = self.loadPhotosFromFeed(feed)
        var feedUser = User(id: 0, firstName: "Unknown", secondName: "", userPhotoURLString: nil)
        if let user = self.userService.getByID(feed.sourceID) {
            feedUser = user
        }
        return Feed(user: feedUser, photos: photosURLs, feed: feed)
    }
    
    private func configurateGroupFeed(_ feed: FeedDTO) -> Feed {
        let photosURLs = self.loadPhotosFromFeed(feed)
        var feedGroup = Group(id: 0, title: "Unknown", imageURL: nil)
        if let group = self.groupService.getByID(feed.sourceID) {
            feedGroup = group
        }
        return Feed(group: feedGroup, photos: photosURLs, feed: feed)
    }
    
    private func loadPhotosFromFeed(_ feed: FeedDTO) -> [Photo]? {
        guard let images = feed.photosURLs else { return nil }
        let photos = images.compactMap { $0.photo }
        let photoSizes = photos.map { $0.photos }
        return photoSizes.map { Photo(imageURLString: $0?.last?.url) }
    }
    
}
