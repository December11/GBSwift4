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
    
    init(group: RealmGroup) {
        self.id = group.id
        self.title = group.title
        self.groupPictureURL = group.groupPhotoURL ?? nil
        self.codeColor = group.codeColor
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
