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
    var codeColor = CGColor.generateLightColor()
}

extension RealmUser {    
    convenience init(user: User) {
        self.init()
        self.id = user.id
        self.firstName = user.firstName
        self.secondName = user.secondName
        self.userPhotoURLString = user.userPhotoURLString
        self.codeColor = user.codeColor
    }
    convenience init(fromDTO: UserDTO) {
        self.init()
        self.id = fromDTO.id ?? 0
        self.firstName = fromDTO.firstName ?? "Anonymous"
        self.secondName = fromDTO.secondName ?? ""
        self.userPhotoURLString = fromDTO.photoURLString
        self.deactivated = fromDTO.deactivated
        self.codeColor = CGColor.generateLightColor()
    }
}
