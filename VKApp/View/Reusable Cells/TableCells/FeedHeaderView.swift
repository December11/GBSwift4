//
//  FeedHeaderView.swift
//  VKApp
//
//  Created by Alla Shkolnik on 21.04.2022.
//

import UIKit

final class FeedHeaderView: UIView {
    
    private let view = UITableViewHeaderFooterView()
    private let headerView: ImageCell = UIView.fromNib()
    
    func configurateHeader(feed: Feed) -> UIView {
        if let user = feed.user {
            headerView.configureFeedCell(
                label: user.userName,
                pictureURL: user.userPhotoURLString,
                color: user.codeColor,
                date: feed.date
            )
        } else if let group = feed.group {
            headerView.configureFeedCell(
                label: group.title,
                pictureURL: group.groupPictureURL,
                color: group.codeColor,
                date: feed.date
            )
        }
        return view
    }
    
    func setupConstraints() {
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
