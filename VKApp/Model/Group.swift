//
//  Group.swift
//  VKApp
//
//  Created by Alla Shkolnik on 25.12.2021.
//

import UIKit

struct Group {
    let id: Int
    let title: String
    let groupPictureURL: String?
    let codeColor: CGColor
    
    init(id: Int, title: String, imageURL: String?) {
        self.id = id
        self.title = title
        self.groupPictureURL = imageURL ?? nil
        codeColor = CGColor.generateLightColor()
    }
    
    init(fromRealm: RealmGroup) {
        self.id = fromRealm.id
        self.title = fromRealm.title
        self.groupPictureURL = fromRealm.groupPhotoURL ?? nil
        self.codeColor = fromRealm.codeColor
    }
}

extension Group: Comparable {
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.title == rhs.title
    }
    
    static func < (lhs: Group, rhs: Group) -> Bool {
        lhs.title < rhs.title
    }
}
