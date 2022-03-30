//
//  FeedStorage.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.01.2022.
//

import UIKit

final class FeedStorage {
    static let shared = FeedStorage()

    var feedNews = [Feed]()
    
    private init() {
        
//        addNewsToFeed(
//            Feed(user: FriendStorage.shared.friends[7],
//                 messageText: "Some message",
//                 image: [
//                    Photo(image: UIImage(named: "groupPhoto2.png")),
//                    Photo(image: UIImage(named: "groupPhoto1.png")),
//                    Photo(image: UIImage(named: "groupPhoto2.png")),
//                    Photo(image: UIImage(named: "groupPhoto1.png")),
//                    Photo(image: UIImage(named: "groupPhoto2.png")),
//                    Photo(image: UIImage(named: "groupPhoto1.png")),
//                    Photo(image: UIImage(named: "groupPhoto2.png"))
//                 ])
//        )
//        addNewsToFeed(
//            Feed(user: FriendStorage.shared.friends[12],
//                 messageText: "another some message. Maybe so long to be on two strings, maybe no",
//                 image: nil)
//        )
//        addNewsToFeed(
//            Feed(user: FriendStorage.shared.friends[2],
//                 messageText: "another some message. Maybe so long to be on two strings",
//                 image: [
//                    Photo(image: UIImage(named: "groupPhoto1.png")),
//                    Photo(image: UIImage(named: "groupPhoto2.png"))
//                 ])
//        )
//        addNewsToFeed(
//            Feed(user: FriendStorage.shared.friends[8],
//                 messageText: "another some message. Maybe so long to be on two strings",
//                 image: [Photo(image: UIImage(named: "groupPhoto1.png"))])
//        )
//        addNewsToFeed(
//            Feed(user: FriendStorage.shared.friends[2],
//                 messageText: "another some message. Maybe so long to be on two strings",
//                 image: nil)
//        )
//        addNewsToFeed(
//            Feed(user: FriendStorage.shared.friends[0],
//                 messageText: nil,
//                 image: nil)
//        )
//        addNewsToFeed(
//            Feed(user: FriendStorage.shared.friends[8],
//                 messageText: nil,
//                 image: [Photo(image: UIImage(named: "groupPhoto1.png"))])
//        )
        feedNews = feedNews.sorted { $0 > $1 }
    }
    
    func addNewsToFeed(_ feed: Feed) {
        guard feed.messageText?.isEmpty == false || !feed.images.isEmpty else { return }
        
        feedNews.append(feed)
    }
}
