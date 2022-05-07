//
//  FeedCell.swift
//  VKApp
//
//  Created by Alla Shkolnik on 15.01.2022.
//

import Kingfisher
import UIKit

final class FeedCell: UITableViewCell {
    @IBOutlet weak var feedMessage: UILabel!
    @IBOutlet weak var showMoreButton: UIButton!
    @IBOutlet weak var messageBottomConstaint: NSLayoutConstraint!
    private let maxLines = 4
    var feed: Feed?
    var showMoreHandler: () -> () = {}
    
    func configureFeedCell(feed: Feed, handler: @escaping () -> ()) {
        self.feed = feed
        self.showMoreHandler = handler
        updateExpanded(feed.isExpanded)
        feedMessage.isHidden = feed.messageText == nil
        feedMessage.text = feed.messageText
        showMoreButton.isHidden = feedMessage.linesCount <= maxLines
        if !showMoreButton.isHidden {
            messageBottomConstaint.constant = 8
        } else {
            messageBottomConstaint.constant = -32
        }
        self.layoutIfNeeded()
    }
    
    override func awakeFromNib() {
        showMoreButton.configuration?.background.backgroundColor = .clear
    }
    
    // MARK: - Private functions
    private func anyObject(of feed: Feed) -> [Any] {
        var array = [String]()
        if let message = feed.messageText {
            array.append(message)
        }
        return !feed.photos.isEmpty ? feed.photos : array
    }
    
    private func updateExpanded(_ isExpaned: Bool) {
        showMoreButton.isSelected = feed?.isExpanded ?? false
        feedMessage.numberOfLines = showMoreButton.isSelected ? 0 : maxLines
        showMoreButton.setTitle(isExpaned ? "Скрыть" : "Показать больше", for: .init())
    }
    
    @IBAction func showMore(_ sender: UIButton) {
        feed?.isExpanded.toggle()
        updateExpanded(feed?.isExpanded ?? false)
        showMoreHandler()
    }
}
