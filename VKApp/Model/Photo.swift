//
//  Photo.swift
//  VKApp
//
//  Created by Alla Shkolnik on 03.01.2022.
//

import UIKit

final class Photo {
    let imageURLString: String?
    let width: Int
    let height: Int
    var aspectRatio: CGFloat {
        CGFloat(width) / CGFloat(height)
    }
    var isLiked = false
    
    init(imageURLString: String?, width: Int = 0, height: Int = 0) {
        self.imageURLString = imageURLString
        self.height = height
        self.width = width
    }
}
