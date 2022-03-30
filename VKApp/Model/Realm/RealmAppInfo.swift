//
//  RealmAppInfo.swift
//  VKApp
//
//  Created by Alla Shkolnik on 26.02.2022.
//

import Foundation
import RealmSwift

class RealmAppInfo: Object {
    @Persisted(primaryKey: true) var id: String?
    @Persisted var friendsUpdateDate: Date?
    @Persisted var groupsUpdateDate: Date?
    @Persisted var feedUpdateDate: Date?
}

extension RealmAppInfo {
    convenience init(groupsUpdateDate: Date?, friendsUpdateDate: Date?, feedUpdateDate: Date?) {
        self.init()
        self.id = "1"
        if let newValue = groupsUpdateDate {
            self.groupsUpdateDate = newValue
        }
        if let newValue = friendsUpdateDate {
            self.friendsUpdateDate = newValue
        }
        if let newValue = feedUpdateDate {
            self.feedUpdateDate = newValue
        }
    }
}
