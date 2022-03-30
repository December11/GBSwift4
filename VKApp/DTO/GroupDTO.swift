//
//  GroupDTO.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.02.2022.
//

import Foundation

struct GroupDTO {
    let id: Int
    var title: String
    var groupPhotoURL: String
    
}

extension GroupDTO: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case groupPhotoURL = "photo_50"
    }
}
