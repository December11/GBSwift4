//
//  PhotoSizesDTO.swift
//  VKApp
//
//  Created by Alla Shkolnik on 18.02.2022.
//

import UIKit

struct PhotoInfosDTO {
    let sizeType: String
    let url: String
}

extension PhotoInfosDTO: Decodable {
    enum CodingKeys: String, CodingKey {
        case url
        case sizeType = "type"
    }
}
