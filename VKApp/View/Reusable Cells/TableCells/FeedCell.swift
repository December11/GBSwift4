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
    var feed: Feed?
    
    func configureFeedCell(feed: Feed) {
        self.feed = feed
        showMoreButton.isHidden = feed.messageText?.count ?? 0 <= 100
        print("## showMoreButton.isHidden is \(showMoreButton.isHidden)")
        if !showMoreButton.isHidden { 
            showMoreButton.setTitle("Показать больше", for: .init())
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
        sender.isSelected.toggle()
        let title = showMoreButton.isSelected ? "Скрыть" : "Показать больше"
        print("## Is button pressed? -\(showMoreButton.isSelected)")
        showMoreButton.setTitle(title, for: .normal)
    }
}
