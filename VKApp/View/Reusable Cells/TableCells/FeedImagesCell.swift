//
//  FeedImageCell.swift
//  VKApp
//
//  Created by Alla Shkolnik on 30.03.2022.
//

import Kingfisher
import UIKit

final class FeedImagesCell: UITableViewCell {
    @IBOutlet weak var imgScrollView: UIScrollView!
    @IBOutlet weak var imgView: UIView!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var feed: Feed?
    var feedImageViews = [UIImageView]()
    
    func configureFeedCell(feed: Feed) {
        self.feed = feed
        imgView.isHidden = feed.photos.count <= 1
        loadPhotos(of: feed)
    }
    
    private func loadSinglePhoto(_ feed: Feed) {
        feedImageView.isHidden = false
        let photo = feed.photos.first
        imageHeightConstraint.constant = UIScreen.main.bounds.width / (photo?.aspectRatio ?? 1)
        self.layoutSubviews()
        if let imageURLString = photo?.imageURLString,
           let url = URL(string: imageURLString) {
            feedImageView.kf.setImage(with: url)
        }
        feedImageView.contentMode = .scaleAspectFit
    }
    
    private func loadSeveralPhotos(_ feed: Feed) {
        imgScrollView.isHidden = false
        imgView.isHidden = false
        pageControl.isHidden = false
        imgScrollView.contentSize = CGSize(
            width: (UIScreen.main.bounds.width) * CGFloat(feed.photos.count),
            height: UIScreen.main.bounds.width
        )
        for index in 0..<feed.photos.count {
            let imageView = UIImageView()
            feedImageViews.append(imageView)
            
            if let imageURLString = feed.photos[index].imageURLString,
               let url = URL(string: imageURLString) {
                imageView.kf.setImage(with: url)
            }
            feedImageViews[index].frame = CGRect(
                x: (UIScreen.main.bounds.width) * CGFloat(index),
                y: 0,
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.width
            )
            feedImageViews[index].contentMode = .scaleAspectFit
            imgScrollView.cornerRadius = 8
            imgScrollView.addSubview(feedImageViews[index])
        }
        pageControl.numberOfPages = feed.photos.count
    }
    
    private func loadPhotos(of feed: Feed) {
        feedImageViews.removeAll()
        imgScrollView.subviews.forEach {
            $0.removeFromSuperview()
        }
        imgScrollView.isHidden = true
        imgView.isHidden = true
        feedImageView.isHidden = true
        pageControl.isHidden = true
        
        if feed.photos.count == 1 {
            loadSinglePhoto(feed)
            
        } else {
            loadSeveralPhotos(feed)
        }
    }
}

extension FeedImagesCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = floor(scrollView.contentOffset.x / scrollView.bounds.width)
        self.pageControl.currentPage = Int(page)
    }
}
