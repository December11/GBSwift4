//
//  ResponseDTO.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.02.2022.
//

import Foundation

struct ResponseDTO<ItemsType: Decodable>: Decodable {
    let response: ItemsDTO<ItemsType>
}

