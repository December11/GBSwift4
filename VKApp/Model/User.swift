//
//  Friend.swift
//  VKApp
//
//  Created by Alla Shkolnik on 25.12.2021.
//

import UIKit

final class User {
    let id: Int
    let firstName: String
    let secondName: String
    var userName: String {
        firstName + " " + secondName
    }
    var userPhotoURLString: String?
    let codeColor: CGColor
    
    init(id: Int, firstName: String, secondName: String, userPhotoURLString: String?) {
        self.id = id
        self.firstName = firstName
        self.secondName = secondName
        self.userPhotoURLString = userPhotoURLString ?? nil
        self.codeColor = CGColor.generateLightColor()
    }
    
    init(fromRealm: RealmUser) {
        self.id = fromRealm.id
        self.firstName = fromRealm.firstName
        self.secondName = fromRealm.secondName
        self.userPhotoURLString = fromRealm.userPhotoURLString ?? nil
        self.codeColor = fromRealm.codeColor
    }
}

extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        lhs.secondName < rhs.secondName
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.userName == rhs.userName
    }
}
