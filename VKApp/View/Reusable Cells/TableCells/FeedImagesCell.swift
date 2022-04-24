//
//  FeedImageCell.swift
//  VKApp
//
//  Created by Alla Shkolnik on 30.03.2022.
//

import UIKit

final class FeedImagesCell: UITableViewCell {
    @IBOutlet weak var imgScrollView: UIScrollView!
    @IBOutlet weak var imgView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var feed: Feed?
    var feedImageViews = [UIImageView]()
    
    func configureFeedCell(feed: Feed) {
        self.feed = feed
        imgView.isHidden = feed.photos.isEmpty
        loadPhotos(of: feed)
    }
    
    private func loadPhotos(of feed: Feed) {
        
        imgScrollView.contentSize = CGSize(
            width: (UIScreen.main.bounds.width - 32) * CGFloat(feed.photos.count),
            height: UIScreen.main.bounds.width - 32
        )
        imgScrollView.subviews.forEach {
            $0.removeFromSuperview()
        }
        feedImageViews.removeAll()
        for index in 0..<feed.photos.count {
            let imageView = UIImageView()
            feedImageViews.append(imageView)
            
            if let imageURLString = feed.photos[index].imageURLString,
               let url = URL(string: imageURLString) {
                imageView.kf.setImage(with: url)
            }
            feedImageViews[index].frame = CGRect(
                x: (UIScreen.main.bounds.width - 32) * CGFloat(index),
                y: 0,
                width: UIScreen.main.bounds.width - 32,
                height: UIScreen.main.bounds.width - 32
            )
            feedImageViews[index].contentMode = .scaleAspectFill
            imgScrollView.cornerRadius = 8
            imgScrollView.addSubview(feedImageViews[index])
        }
        pageControl.numberOfPages = feed.photos.count
    }
}

extension FeedImagesCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = floor(scrollView.contentOffset.x / scrollView.bounds.width)
        self.pageControl.currentPage = Int(page)
    }
}
