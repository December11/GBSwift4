//
//  PhotosCollectionViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 18.12.2021.
//

import UIKit

final class FriendCollectionViewController: UICollectionViewController {
    
    var friend: User?
    private var friendPhotos = [Photo]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let userID = friend?.id else { return }
        let photoService = PhotoService.shared
        photoService.fetchPhotosFromJSON(userID) { [weak self] _ in
            self?.friendPhotos = photoService.userPhotos
        }
        collectionView.register(ImageCollectionCell.self)
    }

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
