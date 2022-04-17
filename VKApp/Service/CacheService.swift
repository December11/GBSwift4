//
//  CachePhotoService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 16.04.2022.
//

import Kingfisher
import UIKit

final class CachePhotoService {
    private let cacheLifetime: TimeInterval = 60 * 60
    private var images = [String: UIImage]()
    private static var pathName: String {
        let pathName = String(describing: User.self) + "Photos"
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        
        guard let cacheDirectory = cacheDirectory else { return pathName }
        
        let url = cacheDirectory.appendingPathComponent(pathName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return pathName
    }
    
    private func getFilePath(url: String) -> String? {
        let generalCacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        print(generalCacheDirectory?.path)
        guard let cacheDirectory = generalCacheDirectory else { return nil }
        let title = url.split(separator: "/").last ?? "default"
        print("## 2. pathName is \(CachePhotoService.pathName + "/" + title)")
        return cacheDirectory.appendingPathComponent(CachePhotoService.pathName + "/" + title).path
    }
    
    func saveImageToCache(url: String) {
        print("## 0. url is \(url)")
        let downloadOperation = ImageDownloadOperation(url: url)
        downloadOperation.completionBlock = {
            print("## 0.1 downloadOperation completion block!")
            guard
                let image = downloadOperation.image,
                let filepath = self.getFilePath(url: url),
                let data = image.pngData()
            else { return }
            FileManager.default.createFile(atPath: filepath, contents: data, attributes: nil)
            print("## 3. file was created at \(filepath)")
        }
        
        OperationQueue.main.addOperation(downloadOperation)
    }
    
    private func getImageFromCache(url: String) -> UIImage? {
        guard
            let filename = getFilePath(url: url),
            let lifetime = getFileLifetime(url: url),
            lifetime <= cacheLifetime
        else { return nil }
        
        let image = UIImage(contentsOfFile: filename)
        DispatchQueue.global().async {
            self.images[url] = image
        }
        return image
    }
    
    private func getFileLifetime(url: String) -> TimeInterval? {
        guard
            let filename = getFilePath(url: url),
            let info = try? FileManager.default.attributesOfItem(atPath: filename),
            let modificationDate = info[FileAttributeKey.modificationDate] as? Date
        else { return nil }

        return Date().timeIntervalSince(modificationDate)
    }
}
