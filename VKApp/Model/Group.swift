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
    
    init (_ object: RealmSavedGroup) {
        self.id = object.id
        self.groupPictureURL = object.groupPhotoURL
        self.title = object.title
        self.codeColor = object.codeColor
    }
}
