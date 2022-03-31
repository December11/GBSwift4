//
//  FeedCell.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.01.2022.
//

import UIKit
import Kingfisher

final class FeedCell: UITableViewCell {
    @IBOutlet weak var feedMessage: UILabel!
//    @IBOutlet weak var imgScrollView: UIScrollView!
//    @IBOutlet weak var imgView: UIView!
//    @IBOutlet weak var pageControl: UIPageControl!
    
//    var feedImageViews = [UIImageView]()
    var feed: Feed?
    
    func configureFeedCell(feed: Feed) {
        
        self.feed = feed
        
        feedMessage.isHidden = feed.messageText == nil
        feedMessage.text = feed.messageText
        //imgView.isHidden = feed.photos.isEmpty
        //loadPhotos(of: feed)
        
    }
    
    //MARK: - Private functions
    private func anyObject(of feed: Feed) -> [Any] {
        var array = [String]()
        if let message = feed.messageText {
            array.append(message)
        }
        return !feed.photos.isEmpty ? feed.photos : array
    }
}
    
//    private func loadPhotos(of feed: Feed) {
//
//        imgScrollView.contentSize = CGSize(width: (UIScreen.main.bounds.width - 32) * CGFloat(feed.photos.count),
//                                          height: UIScreen.main.bounds.width - 32)
//        imgScrollView.subviews.forEach {
//            $0.removeFromSuperview()
//        }
//        feedImageViews.removeAll()
//        for i in 0..<feed.photos.count {
//            let imageView = UIImageView()
//            feedImageViews.append(imageView)
//
//            if let imageURLString = feed.photos[i].imageURLString,
//               let url = URL(string: imageURLString) {
//                imageView.kf.setImage(with: url)
//            }
//            feedImageViews[i].frame = CGRect(x: (UIScreen.main.bounds.width - 32) * CGFloat(i),
//                                             y: 0,
//                                             width: UIScreen.main.bounds.width - 32,
//                                             height: UIScreen.main.bounds.width - 32)
//            feedImageViews[i].contentMode = .scaleAspectFit
//            imgScrollView.cornerRadius = 8
//            imgScrollView.addSubview(feedImageViews[i])
//        }
//        pageControl.numberOfPages = feed.photos.count
//    }
//
//}
//
//extension FeedCell: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let page = floor(scrollView.contentOffset.x / scrollView.bounds.width)
//        pageControl.currentPage = Int(page)
//    }
//}
