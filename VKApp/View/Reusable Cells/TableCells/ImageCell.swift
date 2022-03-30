//
//  ImageCell.swift
//  VKApp
//
//  Created by Alla Shkolnik on 25.12.2021.
//

import UIKit
import Kingfisher

class ImageCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var photo: UIImageView!
    @IBOutlet weak var abbreviationLabel: UILabel!
    @IBOutlet weak var userPicView: UIView!
    
    func configureCell(label: String, additionalLabel: String?, pictureURL: String?, color: CGColor?) {
        
        // имя или название
        // делаем фамилию жирной, если это список друзей
        let attributedString = NSMutableAttributedString(string: label)
        if let secondName = additionalLabel {
            attributedString.append(NSMutableAttributedString(string: " "))
            attributedString.append(secondName.bold)
        }
        self.label.attributedText = attributedString
        
        // акроним
        let picture = pictureURL == "https://vk.com/images/camera_50.png" || pictureURL == "https://vk.com/images/community_50.png"
        ? nil
        : pictureURL
        abbreviationLabel.isHidden = picture != nil
        let name = additionalLabel == nil ? label : label + " " + additionalLabel!
        abbreviationLabel.text = picture == nil ? name.acronym : nil
        userPicView.layer.backgroundColor = color ?? UIColor.yellow.cgColor
        
        // фотка
        photo.isHidden = pictureURL == nil
        if let imageURL = picture {
            let url = URL(string: imageURL)
            photo.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        } else {
            photo.image = nil
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func awakeFromNib() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(userPhotoTapped(_:)))
        userPicView.addGestureRecognizer(gesture)
    }
    
    @objc func userPhotoTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.1) {
            self.userPicView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.userPicView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
}

