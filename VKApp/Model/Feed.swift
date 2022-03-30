//
//  Feed.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.01.2022.
//

import Foundation

final class Feed {
    let date: Date
    let user: User?
    let group: Group?
    
    var messageText: String?
    var photos = [Photo]()
    
    var isLiked = false {
        didSet {
            if isLiked {
                likesCount += 1
            } else {
                likesCount -= 1
            }
        }
    }
    var likesCount: Int
    var commentsCount: Int
    var viewsCount: Int
    
    init(user: User?, messageText: String?, photos: [Photo]?, date: Date, likesCount: Int = 0, commentsCount: Int = 0, viewsCount: Int = 0) {
        self.user = user
        self.messageText = messageText
        if let value = photos {
            self.photos = value
        }
        self.date = date
        self.group = nil
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.viewsCount = viewsCount
    }
    
    init(group: Group?, messageText: String?, photos: [Photo]?, date: Date, likesCount: Int = 0, commentsCount: Int = 0, viewsCount: Int = 0) {
        self.group = group
        self.messageText = messageText
        if let value = photos {
            self.photos = value
        }
        self.date = date
        self.user = nil
        self.likesCount = likesCount
        self.commentsCount = commentsCount
        self.viewsCount = viewsCount
    }
}
