//
//  PhotosCollectionViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 18.12.2021.
//

import UIKit

class FriendCollectionViewController: UICollectionViewController {
    
    var friend: User?
    var friendPhotos = [Photo]()
    
    private let photosService = NetworkService<PhotoDTO>()
    private var photosDTOObject = [PhotoDTO]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userID = friend?.id else { return }
        
        //получаем мои фотки
        photosService.path = "/method/photos.get"
        photosService.queryItems = [
            URLQueryItem(name: "owner_id", value: String(userID)),
            URLQueryItem(name: "album_id", value: "profile"),
            URLQueryItem(name: "access_token", value: SessionStorage.shared.token),
            URLQueryItem(name: "v", value: "5.131")
        ]
        photosService.fetch { [weak self] photosDTOObject in
            switch photosDTOObject {
            case .failure(let error):
                print(error)
            case .success(let fetchedPhotos):
                fetchedPhotos.forEach { photo in
                    photo.photos.forEach { info in
                        if info.sizeType == "x" {
                            self?.friendPhotos.append(Photo(imageURLString: info.url))
                        }
                    }
                }
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
        collectionView.register(UINib(nibName: "ImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: "imageCollectionCell")
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "photoPreview"{
            guard
                let photoPreviewController = segue.destination as? PhotoPreviewViewController,
                let indexPath = sender as? IndexPath
            else { return }
            let currentPhoto = friendPhotos[indexPath.item]
            photoPreviewController.currentActivePhoto = currentPhoto
            photoPreviewController.photos = friendPhotos
            photoPreviewController.activePhotoIndex = indexPath.item
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendPhotos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "imageCollectionCell",
                for: indexPath)
                as? ImageCollectionCell
        else { return UICollectionViewCell() }
        cell.configureItem(picture: friendPhotos[indexPath.row])
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "photoPreview", sender: indexPath)
    }

}

extension FriendCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: collectionView.bounds.width)
    }
}
