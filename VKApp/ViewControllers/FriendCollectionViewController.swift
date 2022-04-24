//
//  PhotosCollectionViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 18.12.2021.
//

import UIKit

class FriendCollectionViewController: UICollectionViewController {
    
    var friend: User?
    var friendPhotos = [Photo]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private var photosDTOObject = [PhotoDTO]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userID = friend?.id else { return }
        
        fetchPhotosFromJSON(userID)
        collectionView.register(ImageCollectionCell.self)
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
    
    // MARK: - Private methods
    private func fetchPhotosFromJSON(_ userID: Int) {
        let photosService = NetworkService<PhotoDTO>()
        guard
            let accessToken = VKWVLoginViewController.keychain.get("accessToken")
        else { return }
        
        photosService.path = "/method/photos.get"
        photosService.queryItems = [
            URLQueryItem(name: "owner_id", value: String(userID)),
            URLQueryItem(name: "album_id", value: "profile"),
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "v", value: "5.131")
        ]
        photosService.fetch { [weak self] photosDTOObject in
            switch photosDTOObject {
            case .failure(let error):
                print("## Error. Can't load friend's photos", error)
            case .success(let fetchedPhotos):
                fetchedPhotos.forEach { photo in
                    photo.photos?.forEach { info in
                        if info.sizeType == "x" {
                            self?.friendPhotos.append(Photo(imageURLString: info.url))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendPhotos.count
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: ImageCollectionCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configureItem(picture: friendPhotos[indexPath.row])
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "photoPreview", sender: indexPath)
    }
}

extension FriendCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: collectionView.bounds.width)
    }
}
