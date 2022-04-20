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
    
    let session = URLSession.shared
    
    init(url: String) {
        self.url = url
    }
    
    override func main() {
        guard
            isAvatarExist(url),
            let url = URL(string: url)
        else { return }
      
        let task = self.session.dataTask(with: url) { [weak self] data, _, error in
            guard
                error == nil,
                let data = data
            else {
                print("## Error 0. Can't load data", error)
                self?.image = nil
                return
            }
            self?.image = UIImage(data: data)
            self?.state = .finished
        }
        task.resume()
    }
    
    private func isAvatarExist(_ url: String) -> Bool {
        return url != "https://vk.com/images/camera_50.png" && url != "https://vk.com/images/community_50.png"
    }
}
