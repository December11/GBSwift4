//
//  FeedCell.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.01.2022.
//

import UIKit
import Kingfisher

final class FeedCell: UITableViewCell {
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var feedCreationDate: UILabel!
    @IBOutlet weak var userPhotoBackground: UIView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var acronym: UILabel!
    @IBOutlet weak var feedMessage: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var imgScrollView: UIScrollView!
    @IBOutlet weak var imgView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var viewsCountLabel: UILabel!
    
    var feedImageViews = [UIImageView]()
    var feed: Feed?
    var onShare: () -> () = {}
    
    func configureFeedCell(feed: Feed, isLast: Bool, onShare: @escaping () -> ()) {
        
        self.feed = feed
        self.onShare = onShare
        
        loadUserORGroup(of: feed)
        
        feedCreationDate.text = feed.date.toString(dateFormat: .dateTime)
        feedMessage.isHidden = feed.messageText == nil
        feedMessage.text = feed.messageText
        imgView.isHidden = feed.photos.isEmpty
        //self.userPhoto.image = nil
        
        loadPhotos(of: feed)
        loadLikes(of: feed)
        loadComments(of: feed)
        loadViews(of: feed)
        
        separator.isHidden = isLast
        
    }
    
    override func awakeFromNib() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(userPhotoTapped(_:)))
        userPhotoBackground.addGestureRecognizer(gesture)
        likeButton.configuration?.background.backgroundColor = .clear
    }
    
    @objc
    func userPhotoTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.2) { 
            self.userPhotoBackground.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.userPhotoBackground.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    //MARK: - Private functions
    private func anyObject(of feed: Feed) -> [Any] {
        var array = [String]()
        if let message = feed.messageText {
            array.append(message)
        }
        return !feed.photos.isEmpty ? feed.photos : array
    }
    
    private func loadUserORGroup(of feed: Feed) {
        if let user = feed.user {
            userName.text = user.userName
            userPhotoBackground.backgroundColor = UIColor(cgColor: user.codeColor)
            userPhoto.isHidden = user.userPhotoURLString == nil
            if let url = URL(string: user.userPhotoURLString ?? "") {
                userPhoto.kf.setImage(with: url)
            }
            acronym.isHidden = user.userPhotoURLString != nil
            acronym.text = user.userName.acronym
        } else if let group = feed.group {
            userName.text = group.title
            userPhotoBackground.backgroundColor = UIColor(cgColor: group.codeColor)
            userPhoto.isHidden = group.groupPictureURL == nil
            if let url = URL(string: group.groupPictureURL ?? "") {
                userPhoto.kf.setImage(with: url)
            }
            acronym.isHidden = group.groupPictureURL != nil
            acronym.text = group.title.acronym
        }
    }
    
    private func loadPhotos(of feed: Feed) {
        
        imgScrollView.contentSize = CGSize(width: (UIScreen.main.bounds.width - 32) * CGFloat(feed.photos.count),
                                          height: UIScreen.main.bounds.width - 32)
        imgScrollView.subviews.forEach {
            $0.removeFromSuperview()
        }
        feedImageViews.removeAll()
        for i in 0..<feed.photos.count {
            let imageView = UIImageView()
            feedImageViews.append(imageView)
            
            if let imageURLString = feed.photos[i].imageURLString,
               let url = URL(string: imageURLString) {
                imageView.kf.setImage(with: url)
            }
            feedImageViews[i].frame = CGRect(x: (UIScreen.main.bounds.width - 32) * CGFloat(i),
                                             y: 0,
                                             width: UIScreen.main.bounds.width - 32,
                                             height: UIScreen.main.bounds.width - 32)
            feedImageViews[i].contentMode = .scaleAspectFit
            imgScrollView.cornerRadius = 8
            imgScrollView.addSubview(feedImageViews[i])
        }
        pageControl.numberOfPages = feed.photos.count
    }
    
    private func loadLikes(of feed: Feed) {
        feed.likesCount += feed.isLiked ? 1 : 0
        self.likeButton.setTitle(String(feed.likesCount), for: .init())
    }
    
    private func loadComments(of feed: Feed) {
        self.replyButton.setTitle(String(feed.commentsCount), for: .init())
    }
    
    private func loadViews(of feed: Feed) {
        self.viewsCountLabel.text = String(feed.viewsCount)
    }
    
    //MARK: - Animations
    private func likeAnimate() {
        UIView.transition(with: self.likeButton, duration: 0.1, options: .transitionCrossDissolve) { [self] in
            let image = likeButton.isSelected
            ? UIImage(systemName: "hand.thumbsup.circle.fill")
            : UIImage(systemName: "hand.thumbsup.circle")
            likeButton.setImage(image, for: .init())
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseInOut) { [self] in
            likeButton.imageView?.frame.origin.y += 1
        } completion: { [self] isCompletion in
            likeButton.imageView?.frame.origin.y -= 1
        }
    }
    
    private func tapAtImageAnimate() {
        UIView.animate(withDuration: 2.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut) { [self] in
            userPhoto.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } completion: { isCompletion in
            print("tapped on image")
        }
    }
    
    //MARK: - IBActions
    @IBAction func like(_ sender: UIButton) {
        sender.isSelected.toggle()
        feed?.isLiked.toggle()
        
        let count = feed?.likesCount ?? 0
        sender.setTitle(String(count), for: .init())
        likeAnimate()
    }
    
    @IBAction func share(_ sender: Any) {
        self.onShare()
    }
    
}

extension FeedCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = floor(scrollView.contentOffset.x / scrollView.bounds.width)
        pageControl.currentPage = Int(page)
    }
}
