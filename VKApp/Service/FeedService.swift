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
    var nextFrom = ""
    
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
    
    func getFeeds(after date: String, nextFrom: String, completion: @escaping ([Feed]) -> Void) {
        fetchFromJSON(after: date, nextFrom: nextFrom) { feeds in
            self.feedNews = feeds.filter { $0.messageText != "" }
            DispatchQueue.main.async {
                completion(self.feedNews)
            }
        }
    }
    
    func getFeeds(before date: String, nextFrom: String, completion: @escaping ([Feed]) -> Void) {
        fetchFromJSON(before: date, nextFrom: nextFrom) { feeds in
            self.feedNews = feeds.filter { $0.messageText != "" }
            DispatchQueue.main.async {
                completion(self.feedNews)
            }
        }
    }
    
    private func fetchFromJSON(before date: String, nextFrom: String, completion: @escaping ([Feed]) -> Void) {
        let feedService = NetworkService<FeedDTO>()
        guard
            let accessToken = AuthService.shared.keychain.get("accessToken")
        else { return }
        
        feedService.path = "/method/newsfeed.get"
        feedService.queryItems = [
            URLQueryItem(name: "filters", value: "post"),
            URLQueryItem(name: "start_from", value: nextFrom),
            URLQueryItem(name: "end_time", value: date),
            URLQueryItem(name: "count", value: "2"),
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "v", value: "5.131")
        ]
        
        parseData(with: feedService, completion: completion)
    }
    
    private func fetchFromJSON(after date: String, nextFrom: String, completion: @escaping ([Feed]) -> Void) {
        let feedService = NetworkService<FeedDTO>()
        guard
            let accessToken = AuthService.shared.keychain.get("accessToken")
        else { return }
        
        feedService.path = "/method/newsfeed.get"
        feedService.queryItems = [
            URLQueryItem(name: "filters", value: "post"),
            URLQueryItem(name: "start_from", value: nextFrom),
            URLQueryItem(name: "start_time", value: date),
            URLQueryItem(name: "count", value: "2"),
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
                self.nextFrom = fetchOperation.nextFrom
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
        return Feed(group: feedGroup, photos: photosURLs, feed: feed)
    }
    
    private func loadPhotosFromFeed(_ feed: FeedDTO) -> [Photo]? {
        guard let images = feed.photosURLs else { return nil }
        let photosDTO = images.compactMap { $0.photo }
        let photoSizes = photosDTO.map { $0.photos }
        let photos = photoSizes.map { Photo(
                imageURLString: $0?.last?.url,
                width: $0?.last?.width ?? 0,
                height: $0?.last?.height ?? 0
            )
        }
        return photos
    }
    
}
