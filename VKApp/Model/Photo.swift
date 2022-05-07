//
//  Photo.swift
//  VKApp
//
//  Created by Alla Shkolnik on 03.01.2022.
//

import UIKit

final class Photo {
    let imageURLString: String?
    var isLiked = false
    var aspectRatio: CGFloat?
    
    init(imageURLString: String?, width: Int = 0, heigth: Int = 0) {
        self.imageURLString = imageURLString
        self.aspectRatio = CGFloat(heigth) / CGFloat(width)
    }
}
