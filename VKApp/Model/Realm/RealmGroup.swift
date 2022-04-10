//
//  RealmGroup.swift
//  VKApp
//
//  Created by Alla Shkolnik on 26.02.2022.
//

import RealmSwift
import UIKit

class RealmGroup: Object {
    @Persisted(primaryKey: true) var id: Int = 0
    @Persisted var title: String = ""
    @Persisted var groupPhotoURL: String?
    var codeColor = UIColor.systemGray.cgColor
}

extension RealmGroup {
    convenience init (group: Group) {
        self.init()
        self.id = group.id
        self.title = group.title
        self.groupPhotoURL = group.groupPictureURL ?? ""
        self.codeColor = group.codeColor
    }
    convenience init(fromDTO: GroupDTO) {
        self.init()
        self.id = fromDTO.id ?? 0
        self.title = fromDTO.title ?? "Anonymous group"
        self.groupPhotoURL = fromDTO.groupPhotoURL
        self.codeColor = CGColor.generateLightColor()
    }
}
