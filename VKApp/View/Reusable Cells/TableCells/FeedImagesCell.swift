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
                                             height: UIScreen.main.bounds.width - 32
            )
            feedImageViews[i].contentMode = .scaleAspectFit
            imgScrollView.cornerRadius = 8
            imgScrollView.addSubview(feedImageViews[i])
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
