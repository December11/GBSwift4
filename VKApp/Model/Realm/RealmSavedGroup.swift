//
//  RealmSavedGroup.swift
//  VKApp
//
//  Created by Alla Shkolnik on 08.03.2022.
//

import UIKit
import RealmSwift

class RealmSavedGroup: Object {
    @Persisted(primaryKey: true) var id: Int = 0
    @Persisted var title: String = ""
    @Persisted var groupPhotoURL: String?
    var codeColor: CGColor = UIColor.systemGray.cgColor
}

extension RealmSavedGroup {
    convenience init (group: Group) {
        self.init()
        self.id = group.id
        self.title = group.title
        self.groupPhotoURL = group.groupPictureURL
        self.codeColor = group.codeColor
    }
}
