//
//  PhotoService.swift
//  VKApp
//
//  Created by Alla Shkolnik on 24.04.2022.
//

import Foundation

final class PhotoService {
    static let shared = PhotoService()
    var userPhotos = [Photo]()
    
    private init() {}
    
    func fetchPhotosFromJSON(_ userID: Int, completion: @escaping ([Photo]?) -> Void) {
        let photosService = NetworkService<PhotoDTO>()
        guard
            let accessToken = AuthService.shared.keychain.get("accessToken")
        else { return }
        
        photosService.path = "/method/photos.get"
        photosService.queryItems = [
            URLQueryItem(name: "owner_id", value: String(userID)),
            URLQueryItem(name: "album_id", value: "profile"),
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "v", value: "5.131")
        ]
        
        photosService.fetch { [weak self] photosDTO in
            switch photosDTO {
            case .failure(let error):
                print("## Error. Can't load friend's photos", error)
                completion(nil)
            case .success(let fetchedPhotos):
                fetchedPhotos.forEach { photo in
                    photo.photos?.forEach { info in
                        if info.sizeType == "x" {
                            self?.userPhotos.append(
                                Photo(
                                    imageURLString: info.url,
                                    width: info.width ?? 0,
                                    height: info.height ?? 0
                                )
                            )
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion(self?.userPhotos)
                }
            }
        }
    }
}
