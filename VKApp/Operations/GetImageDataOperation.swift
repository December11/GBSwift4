//
//  GetImageDataOperation.swift
//  VKApp
//
//  Created by Alla Shkolnik on 17.04.2022.
//

import Foundation

final class GetImageDataOperation: AsyncOperation {
    var data: Data?
    var filePath: String?
    
    override func main() {
        guard
            let prevOperation = dependencies.first as? ImageDownloadOperation,
            let image = prevOperation.image
        else { return }
        print("## 2.1 Image data getting successfully")
        self.data = image.pngData()
        
        self.state = .finished
    }
}
