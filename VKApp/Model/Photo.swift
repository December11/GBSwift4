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
    
    init(imageURLString: String?) {
        self.imageURLString = imageURLString
    }
}
