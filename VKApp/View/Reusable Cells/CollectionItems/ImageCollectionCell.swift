//
//  imageCollectionCell.swift
//  VKApp
//
//  Created by Alla Shkolnik on 25.12.2021.
//

import UIKit

class ImageCollectionCell: UICollectionViewCell {

    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet weak var imageCollectionView: UIView!
    @IBOutlet weak var photoWidthConstraint: NSLayoutConstraint!
    
    var photo: Photo?
    
    func configureItem(picture: Photo?) {
        self.photo = picture
        guard let imageURL = photo?.imageURLString else { return }
        let url = URL(string: imageURL)
        self.photoImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        self.photoWidthConstraint.constant = UIScreen.main.bounds.width / 3 - 2
    }
}
