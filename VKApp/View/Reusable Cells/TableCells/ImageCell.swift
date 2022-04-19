//
//  ImageCell.swift
//  VKApp
//
//  Created by Alla Shkolnik on 25.12.2021.
//

import Kingfisher
import UIKit

class ImageCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet weak var subTextLabel: UILabel!
    @IBOutlet var photo: UIImageView!
    @IBOutlet weak var abbreviationLabel: UILabel!
    @IBOutlet weak var userPicView: UIView!
    
    // MARK: - Cell configuration methods
    func configureCell(label: String, additionalLabel: String?, pictureURL: String?, color: CGColor?) {
        // имя или название группы
        setUsername(name: label, secondName: additionalLabel)
        self.subTextLabel.isHidden = true
        
        // аватар юзера
        getUserPictire(name: label, addLabel: additionalLabel, url: pictureURL, color: color)
    }
    
    func configureFeedCell(label: String, pictureURL: String?, color: CGColor?, date: Date) {
        // имя или название группы
        self.label.text = label
        self.subTextLabel.text = date.toString(dateFormat: .dateTime)
        
        // аватар юзера
        getUserPictire(name: label, url: pictureURL, color: color)
    }
    
    // MARK: - Private methods
    private func getUserPictire(name: String, addLabel: String? = nil, url: String? = nil, color: CGColor? = nil) {
        abbreviationLabel.isHidden = isUserImageExist(url)
        photo.isHidden = !isUserImageExist(url)
        
        if !isUserImageExist(url) {
            setAcronym(name, additionalLabel: addLabel)
            userPicView.layer.backgroundColor = color ?? UIColor.yellow.cgColor
        } else {
            setUserPhoto(url)
        }
    }
    
    private func setUsername(name: String, secondName: String?) {
        let attributedString = NSMutableAttributedString(string: name)
        if let secondName = secondName {
            attributedString.append(NSMutableAttributedString(string: " "))
            attributedString.append(secondName.bold)
        }
        self.label.attributedText = attributedString
        
        var fullName = name
        if let secondName = secondName {
            fullName += " " + secondName
        }
    }
    
    private func isUserImageExist(_ pictureURL: String?) -> Bool {
        return pictureURL != nil
        && pictureURL != "https://vk.com/images/camera_50.png"
        && pictureURL != "https://vk.com/images/community_50.png"
    }
    
    private func setUserPhoto(_ url: String?) {
        let service = CachePhotoService()
        guard let imageURL = url else { return }
        if let image = service.photo(byUrl: imageURL) {
            self.photo.image = image
        } else {
            print("## Error. No image with such URL \(String(describing: url))")
        }
        
//        let url = URL(string: url)
//        photo.kf.setImage(with: url, options: [.transition(.fade(0.2))])
    }
    
    private func setAcronym(_ label: String, additionalLabel: String? = nil) {
        var fullName = label
        if let label = additionalLabel {
            fullName += label
        }
        abbreviationLabel.text = fullName.acronym
    }
    
    // MARK: - Methods
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
