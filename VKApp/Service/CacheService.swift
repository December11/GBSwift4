//
//  CachePhotoService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 16.04.2022.
//

import Kingfisher
import UIKit

final class CachePhotoService {
    static let shared = CachePhotoService()
    
    private let cacheLifetime: TimeInterval = 60 * 60 * 24
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    var images = [String: UIImage]()
    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    private init() {}
    
    private var pathName: String {
        let pathName = String(describing: User.self) + "Photos"
        guard let directory = documentsDirectory else { return pathName }
        let url = directory.appendingPathComponent(pathName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return pathName
    }
    
    func downloadAndSaveToCache(url: String, completion: @escaping (UIImage?) -> Void) {
        let downloadOperation = ImageDownloadOperation(url: url)
        let getImageDataOperation = GetImageDataOperation()
        getImageDataOperation.addDependency(downloadOperation)
        
        getImageDataOperation.completionBlock = {
            guard let data = getImageDataOperation.data else {
                completion(nil)
                return
            }
            DispatchQueue.global().async {
                self.createFile(url: url, data: data)
                DispatchQueue.main.async {
                    self.images[url] = getImageDataOperation.image
                    completion(getImageDataOperation.image)
                }
            }
        }
        
        queue.addOperation(downloadOperation)
        queue.addOperation(getImageDataOperation)
    }
    
    // MARK: - Private methods
    private func createFile(url: String, data: Data) {
        guard let filepath = self.getFilePath(url: url) else { return }
        FileManager.default.createFile(atPath: filepath, contents: data, attributes: nil)
    }
    
    private func getFilePath(url: String) -> String? {
        print("\(String(describing: documentsDirectory?.path))")
        guard let directory = documentsDirectory else { return nil }
        let title = url.split(separator: "/").last ?? "default"
        return directory.appendingPathComponent(pathName + "/" + title).path
    }
    
    private func getImageFromCache(url: String, completion: @escaping (UIImage?) -> Void) {
        guard
            let filename = getFilePath(url: url),
            let lifetime = getFileLifetime(url: url),
            lifetime <= cacheLifetime
        else {
            completion(nil)
            return
        }
        DispatchQueue.global().async {
            let image = UIImage(contentsOfFile: filename)
            DispatchQueue.main.async {
                self.images[url] = image
                completion(image)
            }
        }
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
    func photo(byUrl url: String, completion: @escaping (UIImage?) -> Void) {
        if let image = images[url] {
            completion(image)
        } else {
            getImageFromCache(url: url) { [weak self] image in
                if let image = image {
                    completion(image)
                } else {
                    self?.downloadAndSaveToCache(url: url) { image in
                        completion(image)
                    }
                }
            }
        }
    }
}
