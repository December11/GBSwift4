//
//  PhotoSizesDTO.swift
//  VKApp
//
//  Created by Alla Shkolnik on 18.02.2022.
//

struct PhotoInfosDTO {
    let sizeType: String?
    let url: String?
    let width: Int?
    let heigth: Int?
}

extension PhotoInfosDTO: Decodable {
    enum CodingKeys: String, CodingKey {
        case url
        case sizeType = "type"
        case width
        case heigth
    }
}
