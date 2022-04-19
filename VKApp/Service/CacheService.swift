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
    var images = [String: UIImage]()
    
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
    
    func downloadAndSaveToCache(url: String) {
        let queue = OperationQueue()
        let downloadOperation = ImageDownloadOperation(url: url)
        let getImageDataOperation = GetImageDataOperation()
        getImageDataOperation.addDependency(downloadOperation)
        
        getImageDataOperation.completionBlock = {
            guard let data = getImageDataOperation.data else { return }
            self.createFile(url: url, data: data)
        }
        
        queue.addOperation(downloadOperation)
        queue.addOperation(getImageDataOperation)
    }
    
    // MARK: - Private methods
    private func createFile(url: String, data: Data) {
        guard let filepath = self.getFilePath(url: url) else { return }
        FileManager.default.createFile(atPath: filepath, contents: data, attributes: nil)
        print("## 3. file was created at \(filepath)")
    }
    
    private func getFilePath(url: String) -> String? {
        let generalCacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        print("\(String(describing: generalCacheDirectory?.path))")
        guard let cacheDirectory = generalCacheDirectory else { return nil }
        let title = url.split(separator: "/").last ?? "default"
        return cacheDirectory.appendingPathComponent(CachePhotoService.pathName + "/" + title).path
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
    
    // MARK: - Public methods
    func photo(byUrl url: String) -> UIImage? {
        var image: UIImage?
        
        if let photo = images[url] {
            image = photo
        } else if let photo = getImageFromCache(url: url) {
            image = photo
        } else {
            downloadAndSaveToCache(url: url)
        }
        return image
    }
}
