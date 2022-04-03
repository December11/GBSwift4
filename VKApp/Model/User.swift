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
    
    init(user: UserDTO) {
        self.id = user.id
        self.firstName = user.firstName
        self.secondName = user.secondName
        self.userPhotoURLString = user.photoURLString 
        self.codeColor = CGColor.generateLightColor() 
    }
    
    init(user: RealmUser) {
        self.id = user.id
        self.firstName = user.firstName
        self.secondName = user.secondName
        self.userPhotoURLString = user.userPhotoURLString ?? nil
        self.codeColor = user.codecolor
    }
    
    func getUserByID(id: Int) -> User? {
        self.id == id ? self : nil
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
