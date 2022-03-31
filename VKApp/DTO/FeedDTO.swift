//
//  FeedDTO.swift
//  VKApp
//
//  Created by Alla Shkolnik on 26.02.2022.
//


//
import Foundation

struct FeedDTO {
    let sourceID: Int
    let date: Double
    let text: String?
    var photosURLs: [PhotoAttachmentDTO]?
    var comments: CommentsDTO
    var likes: LikesDTO
    var views: ViewsDTO?
}

extension FeedDTO: Decodable {
    enum CodingKeys: String, CodingKey {
        case sourceID = "source_id"
        case date
        case text
        case photosURLs = "attachments"
        case comments
        case likes
        case views
    }
}
