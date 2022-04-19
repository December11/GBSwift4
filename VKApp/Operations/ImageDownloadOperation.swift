//
//  ImageDownloadOperation.swift
//  VKApp
//
//  Created by Alla Shkolnik on 16.04.2022.
//

import Kingfisher
import UIKit

final class ImageDownloadOperation: AsyncOperation {
    private(set) var image: UIImage?
    private var url: String
    
    init(url: String) {
        self.url = url
    }
    
    override func main() {
        guard
            isAvatarExist(url),
            let url = URL(string: url)
        else { return }
        
        let imageResource = ImageResource(downloadURL: url, cacheKey: nil)
        KingfisherManager.shared.retrieveImage(with: imageResource.downloadURL) { result in
            switch result {
            case .success(let value):
                self.image = value.image
            case .failure(let error):
                print("## Error. Can't download image with KF, \(error)")
                self.image = nil
            }
            self.state = .finished
        }
    }
    
    private func isAvatarExist(_ url: String) -> Bool {
        return url != "https://vk.com/images/camera_50.png" && url != "https://vk.com/images/community_50.png"
    }
}
