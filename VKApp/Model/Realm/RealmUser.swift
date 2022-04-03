//
//  RealmUser.swift
//  VKApp
//
//  Created by Alla Shkolnik on 26.02.2022.
//

import RealmSwift
import UIKit

class RealmUser: Object {
    @Persisted(primaryKey: true) var id: Int = 0
    @Persisted var firstName: String = ""
    @Persisted var secondName: String = ""
    @Persisted var deactivated: String?
    @Persisted var userPhotoURLString: String?
    var codecolor: CGColor = UIColor.systemGray.cgColor
    
}

extension RealmUser {    
    convenience init(user: User) {
        self.init()
        self.id = user.id
        self.firstName = user.firstName
        self.secondName = user.secondName
        self.userPhotoURLString = user.userPhotoURLString
        self.codecolor = user.codeColor
    }
    
    convenience init(user: UserDTO, color: CGColor) {
        self.init()
        self.id = user.id
        self.firstName = user.firstName
        self.secondName = user.secondName
        self.userPhotoURLString = user.photoURLString
        self.deactivated = user.deactivated
        self.codecolor = color
    }
}
