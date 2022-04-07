//
//  AttachmentDTO.swift
//  VKApp
//
//  Created by Alla Shkolnik on 26.02.2022.
//

import Foundation

struct PhotoAttachmentDTO: Decodable {
    let type: String
    let photo: PhotoDTO?
}
