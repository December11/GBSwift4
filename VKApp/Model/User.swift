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
    
    func getUserByID(id: Int) -> User? {
        self.id == id ? self : nil
    }
  
}
    
