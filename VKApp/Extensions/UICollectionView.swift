//
//  UICollectionView.swift
//  VKApp
//
//  Created by Alla Shkolnik on 04.04.2022.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(_ view: T.Type) {
        let identifier = String(describing: T.self)
        register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        guard
            let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T
        else { fatalError() }
        return cell
    }
}
