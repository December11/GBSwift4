//
//  PhotoPreview.swift
//  VKApp
//
//  Created by Alla Shkolnik on 26.01.2022.
//

import UIKit
import Kingfisher

class PhotoPreviewViewController: UIViewController {
    
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
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipped(_:)))
        rightSwipeGesture.direction = .right
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipped(_:)))
        leftSwipeGesture.direction = .left
        
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissed(_:)))
        downSwipeGesture.direction = .down
        
        currentPhoto.addGestureRecognizer(rightSwipeGesture)
        currentPhoto.addGestureRecognizer(leftSwipeGesture)
        currentPhoto.addGestureRecognizer(downSwipeGesture)
        
        newPhotoLeadingConstraint.constant = UIScreen.main.bounds.width
        newPhotoTrailingConstraint.constant = UIScreen.main.bounds.width
        

        guard let imageURL = currentActivePhoto?.imageURLString else { return }
        let url = URL(string: imageURL)
        self.currentPhoto.kf.setImage(with: url)
        likeButton.configuration?.background.backgroundColor = .clear
    
        likeButton.setTitle("0", for: .init())
        likeButton.setImage(UIImage(systemName: "hand.thumbsup.circle"), for: .init())
        
    }
    
    @objc func dismissed(_ gesture: UISwipeGestureRecognizer) {
        guard gesture.direction == .down else { return }
        
    }
    
    @objc func swipped(_ gesture: UISwipeGestureRecognizer ) {
        guard
            activePhotoIndex != nil,
            let photos = self.photos
        else { return }
        switch(gesture.direction) {
        case .left:
            guard
                let index = getNewIndex(from: self.activePhotoIndex!, isNext: true),
                let imageURL = photos[index].imageURLString
            else { return }
            let url = URL(string: imageURL)
            self.newPhoto.kf.setImage(with: url)
            self.newPhotoLeadingConstraint.constant = UIScreen.main.bounds.width
            newPhotoTrailingConstraint.constant = UIScreen.main.bounds.width
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
                self.currentPhoto.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.currentPhoto.alpha = 0
                self.newPhotoLeadingConstraint.constant = 0
                self.newPhotoTrailingConstraint.constant = 0
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.currentPhoto.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.currentPhoto.alpha = 1
                self.currentPhoto.image = self.newPhoto.image
                self.currentActivePhoto = photos[index]
                self.activePhotoIndex = index
                self.newPhotoLeadingConstraint.constant = UIScreen.main.bounds.width
                self.newPhotoTrailingConstraint.constant = UIScreen.main.bounds.width
                self.updateLikeButton()
            }
            
        case .right:
            guard
                let index = getNewIndex(from: self.activePhotoIndex!, isNext: false),
                let imageURL = photos[index].imageURLString
            else { return }
            let url = URL(string: imageURL)
            self.newPhoto.image = self.currentPhoto.image
            self.currentPhoto.kf.setImage(with: url)
            self.currentPhoto.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.currentPhoto.alpha = 0
            self.newPhotoLeadingConstraint.constant = 0
            newPhotoTrailingConstraint.constant = 0
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
                self.currentPhoto.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.currentPhoto.alpha = 1
                self.newPhotoLeadingConstraint.constant = UIScreen.main.bounds.width
                self.newPhotoTrailingConstraint.constant = UIScreen.main.bounds.width
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.activePhotoIndex = index
                self.currentActivePhoto = photos[index]
                self.updateLikeButton()
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
