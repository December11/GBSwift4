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
        setUsername(name: label, secondName: additionalLabel)
        self.subTextLabel.isHidden = true
        
        getUserPictire(name: label, addLabel: additionalLabel, url: pictureURL, color: color)
    }
    
    func configureFeedCell(label: String, pictureURL: String?, color: CGColor?, date: Date) {
        self.label.text = label
        self.subTextLabel.text = date.toString(dateFormat: .dateTime)
        
        getUserPictire(name: label, url: pictureURL, color: color)
    }
    
    // MARK: - Private methods
    private func getUserPictire(name: String, addLabel: String? = nil, url: String? = nil, color: CGColor? = nil) {
        abbreviationLabel.isHidden = isUserImageExist(url)
        photo.isHidden = !isUserImageExist(url)
        userPicView.layer.backgroundColor = UIColor.systemGray3.cgColor
        
        if !isUserImageExist(url) {
            setAcronym(name, additionalLabel: addLabel)
            userPicView.layer.backgroundColor = nil
            userPicView.layer.backgroundColor = color ?? CGColor.generateLightColor()
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
        guard let imageURL = url else { return }
        CachePhotoService.shared.photo(byUrl: imageURL) { [weak self] _ in
            self?.photo.image = nil
            self?.photo.image = CachePhotoService.shared.images[imageURL]
        }
    }
    
    private func setAcronym(_ label: String, additionalLabel: String? = nil) {
        var fullName = label
        if let label = additionalLabel {
            fullName += label
        }
        abbreviationLabel.text = fullName.acronym
    }
    
    // MARK: - Methods
    
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
