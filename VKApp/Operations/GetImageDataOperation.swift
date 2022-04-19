//
//  GetImageDataOperation.swift
//  VKApp
//
//  Created by Alla Shkolnik on 17.04.2022.
//

import Foundation
import UIKit

final class GetImageDataOperation: AsyncOperation {
    var data: Data?
    var filePath: String?
    var image: UIImage?
    
    override func main() {
        guard
            let prevOperation = dependencies.first as? ImageDownloadOperation,
            let image = prevOperation.image
        else { return }
        self.data = image.pngData()
        self.image = image
        
        self.state = .finished
    }
}
