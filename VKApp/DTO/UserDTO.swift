//
//  ItemsDTO.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.02.2022.
//

import Foundation

struct UserDTO{
    let id: Int
    var firstName: String
    var secondName: String
    var photoURLString: String
    var deactivated: String?
}

extension UserDTO: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case secondName = "last_name"
        case photoURLString = "photo_50"
        case deactivated
        
    }
}
