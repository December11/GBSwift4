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
    
    func getFeeds(completion: @escaping () -> Void) {
        fetchFromJSON { feeds in
            self.feedNews = feeds.filter { $0.messageText != "" }
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func fetchFromJSON(by date: String, completion: @escaping ([Feed]) -> Void) {
        let feedService = NetworkService<FeedDTO>()
        guard
            let accessToken = AuthService.shared.keychain.get("accessToken")
        else { return }
        
        feedService.path = "/method/newsfeed.get"
        feedService.queryItems = [
            URLQueryItem(name: "filters", value: "post"),
            URLQueryItem(name: "start_from", value: "next_from"),
            URLQueryItem(name: "start_time", value: date),
            URLQueryItem(name: "count", value: "5"),
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "v", value: "5.131")
        ]
        
        parseData(with: feedService, completion: completion)
    }
    
    private func fetchFromJSON(completion: @escaping ([Feed]) -> Void) {
        let feedService = NetworkService<FeedDTO>()
        guard
            let accessToken = AuthService.shared.keychain.get("accessToken")
        else { return }
        
        feedService.path = "/method/newsfeed.get"
        feedService.queryItems = [
            URLQueryItem(name: "filters", value: "post"),
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "v", value: "5.131")
        ]
        
        parseData(with: feedService, completion: completion)
    }
    
    private func parseData(with feedService: NetworkService<FeedDTO>, completion: @escaping ([Feed]) -> Void) {
        let fetchOperation = FetchAnyDataOperation<FeedDTO>(service: feedService)
        let queue = OperationQueue()
        queue.addOperation(fetchOperation)
        fetchOperation.completionBlock = {
            DispatchQueue.main.async {
                guard let feedsDTO = fetchOperation.fetchedData else { return }
                let feeds = feedsDTO.map { self.getFeed($0, from: $0.sourceID) }
                completion(feeds)
            }
        }
    }
    
    private func getFeed(_ feed: FeedDTO, from sourceID: Int) -> Feed {
        if sourceID >= 0 {
            return self.configurateUserFeed(feed)
        }
        return self.configurateGroupFeed(feed)
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
        let feedGroup = Group(id: 0, title: "Unknown", imageURL: nil)
        if let group = self.groupService.getByID(feed.sourceID) {
            return Feed(group: group, photos: photosURLs, feed: feed)
        }
        print("## 0.Feed - no group with id \(feed.sourceID) ")
        return Feed(group: feedGroup, photos: photosURLs, feed: feed)
    }
    
    private func loadPhotosFromFeed(_ feed: FeedDTO) -> [Photo]? {
        guard let images = feed.photosURLs else { return nil }
        let photos = images.compactMap { $0.photo }
        let photoSizes = photos.map { $0.photos }
        return photoSizes.map { Photo(imageURLString: $0?.last?.url) }
    }
    
}
