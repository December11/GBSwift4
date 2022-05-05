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
    var feed: Feed?
    var showMoreHandler: () -> () = {}
    
    func configureFeedCell(feed: Feed, handler: @escaping () -> ()) {
        self.feed = feed
        self.showMoreHandler = handler
        showMoreButton.isHidden = feed.messageText?.count ?? 0 <= 100
        if !showMoreButton.isHidden {
            showMoreButton.isSelected = false
            showMoreButton.setTitle("Показать больше", for: .init())
        } else {
             messageBottomConstaint.constant = -32
        }
        feedMessage.isHidden = feed.messageText == nil
        feedMessage.text = feed.messageText
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
    
    @IBAction func showMore(_ sender: UIButton) {
        print("## button is selected? \(sender.isSelected)")
        sender.isSelected.toggle()
        print("## and now - button is selected? \(sender.isSelected)")
        if showMoreButton.isSelected {
            showMoreButton.setTitle("Скрыть", for: .normal)
            feedMessage.numberOfLines = 0
        } else {
            showMoreButton.setTitle("Показать больше", for: .normal)
            feedMessage.numberOfLines = 4
        }
        showMoreHandler()
    }
}
