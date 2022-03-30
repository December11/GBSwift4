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
    var codeColor: CGColor = UIColor.systemGray.cgColor
}

extension RealmGroup {
    convenience init (group: GroupDTO, color: CGColor?) {
        self.init()
        self.id = group.id
        self.title = group.title
        self.groupPhotoURL = group.groupPhotoURL
        self.codeColor = color ?? UIColor.systemGray.cgColor
    }
}
