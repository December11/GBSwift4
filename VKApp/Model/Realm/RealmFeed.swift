//
//  RealmFeed.swift
//  VKApp
//
//  Created by Alla Shkolnik on 13.03.2022.
//

import Foundation
import RealmSwift

final class RealmFeed: Object {
    @Persisted(primaryKey: true) var id = ""
    @Persisted var sourceID: Int?
    @Persisted var date = Date()
    @Persisted var text = ""
    @Persisted var photoURLs: List<String?>
    @Persisted var commentCount = 0
    @Persisted var likeCount = 0
    @Persisted var viewCount = 0
}

extension RealmFeed {
    convenience init(sourceID: Int, date: Date, text: String, commentsCount: Int, likesCount: Int, viewsCount: Int, photoURLs: [String]?)  {
        self.init()
        self.id = String(sourceID) + "_" + date.toString(dateFormat: .dateTime)
        self.sourceID = sourceID
        self.date = date
        self.text = text
        self.commentCount = commentsCount
        self.likeCount = likesCount
        self.viewCount = viewsCount
        if let photos = photoURLs {
            self.photoURLs.append(objectsIn: photos)
        }
    }
}
