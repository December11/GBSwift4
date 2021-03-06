//
//  PhotoPreview.swift
//  VKApp
//
//  Created by Alla Shkolnik on 26.01.2022.
//

import Kingfisher
import UIKit

final class PhotoPreviewViewController: UIViewController {
    
    var photos: [Photo]?
    var currentActivePhoto: Photo?
    var activePhotoIndex: Int?
    
    @IBOutlet weak var currentPhoto: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var newPhoto: UIImageView!
    @IBOutlet weak var newPhotoTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var newPhotoLeadingConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGestureRecognizers()

        guard let imageURL = currentActivePhoto?.imageURLString else { return }
        downloadAndSetImage(url: imageURL, for: currentPhoto)
        
        likeButton.configuration?.background.backgroundColor = .clear
        likeButton.setTitle("0", for: .init())
        likeButton.setImage(UIImage(systemName: "hand.thumbsup.circle"), for: .init())
    }
    
    @objc func dismissed(_ gesture: UISwipeGestureRecognizer) {
        guard gesture.direction == .down else { return }
        dismiss(animated: true, completion: nil)
    }
    
    @objc func swipped(_ gesture: UISwipeGestureRecognizer ) {
        guard
            activePhotoIndex != nil,
            let photos = self.photos
        else { return }
        newPhotoLeadingConstraint.constant = UIScreen.main.bounds.width
        newPhotoTrailingConstraint.constant = UIScreen.main.bounds.width
        switch gesture.direction {
        case .left:
            guard
                let photoIndex = self.activePhotoIndex,
                let index = getNewIndex(from: photoIndex, isNext: true),
                let imageURL = photos[index].imageURLString
            else { return }
            downloadAndSetImage(url: imageURL, for: newPhoto)
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) { [weak self] in
                self?.downscaleAnimation()
            } completion: { [weak self] _ in
                self?.currentPhoto.image = self?.newPhoto.image
                self?.currentActivePhoto = photos[index]
                self?.activePhotoIndex = index
                self?.upscaleAnimation()
                self?.updateLikeButton()
            }
            
        case .right:
            guard
                let photoIndex = self.activePhotoIndex,
                let index = getNewIndex(from: photoIndex, isNext: false),
                let imageURL = photos[index].imageURLString
            else { return }
            newPhoto.image = self.currentPhoto.image
            downloadAndSetImage(url: imageURL, for: currentPhoto)
            downscaleAnimation()
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) { [weak self] in
                self?.upscaleAnimation()
            } completion: { [weak self] _ in
                self?.activePhotoIndex = index
                self?.currentActivePhoto = photos[index]
                self?.updateLikeButton()
            }
        default:
            break
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        currentActivePhoto?.isLiked = !sender.isSelected
        updateLikeButton()
    }
    
    // MARK: - Private functions
    
    private func downscaleAnimation() {
        currentPhoto.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        currentPhoto.alpha = 0
        newPhotoLeadingConstraint.constant = 0
        newPhotoTrailingConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    private func upscaleAnimation() {
        currentPhoto.transform = CGAffineTransform(scaleX: 1, y: 1)
        currentPhoto.alpha = 1
        newPhotoLeadingConstraint.constant = UIScreen.main.bounds.width
        newPhotoTrailingConstraint.constant = UIScreen.main.bounds.width
        view.layoutIfNeeded()
    }
    
    private func downloadAndSetImage(url: String, for imageView: UIImageView) {
        let url = URL(string: url)
        imageView.kf.setImage(with: url)
    }
    
    private func addGestureRecognizers() {
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipped(_:)))
        rightSwipeGesture.direction = .right
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipped(_:)))
        leftSwipeGesture.direction = .left
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissed(_:)))
        downSwipeGesture.direction = .down
        
        currentPhoto.addGestureRecognizer(rightSwipeGesture)
        currentPhoto.addGestureRecognizer(leftSwipeGesture)
        currentPhoto.addGestureRecognizer(downSwipeGesture)
    }
    
    private func getNewIndex(from index: Int, isNext: Bool) -> Int? {
        guard
            let photos = self.photos,
            index != photos.count || index >= 0
        else { return nil }
        
        if isNext {
            return index == photos.count - 1 ? 0 : index + 1
        }
        return index == 0 ? photos.count - 1 : index - 1
    }
    
    private func updateLikeButton() {
        likeButton.isSelected = currentActivePhoto?.isLiked ?? false
        let image = likeButton.isSelected
        ? UIImage(systemName: "hand.thumbsup.circle.fill")
        : UIImage(systemName: "hand.thumbsup.circle")
        likeButton.setImage(image, for: .init())
        likeButton.setTitle("1", for: .selected)
        likeButton.setTitle("0", for: .normal)
    }
}
