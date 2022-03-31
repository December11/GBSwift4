//
//  FeedFooterView.swift
//  VKApp
//
//  Created by Alla Shkolnik on 31.03.2022.
//

import UIKit

class FeedFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    
    var feed: Feed?
    var onShare: () -> () = {}
    
    func configurateFooter(feed: Feed, onShare: @escaping () -> ()) {
        self.feed = feed
        self.onShare = onShare
        
        loadLikes(of: feed)
        loadComments(of: feed)
        loadViews(of: feed)
    }
    
    override func awakeFromNib() {
        likeButton.configuration?.background.backgroundColor = .clear
    }
    
    //MARK: - Private functions
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
