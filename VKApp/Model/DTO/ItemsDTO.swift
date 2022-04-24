//
//  ResponseDTO.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.02.2022.
//

struct ItemsDTO<ItemsType: Decodable>: Decodable {
    let items: [ItemsType]?
    let count: Int?
}
