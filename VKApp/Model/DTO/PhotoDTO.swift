//
//  PhotoDTO.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.02.2022.
//

import UIKit

struct PhotoDTO {
    let id: Int
    let photos: [PhotoInfosDTO]
}

extension PhotoDTO: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case photos = "sizes"
    }
}
