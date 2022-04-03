//
//  UITableView.swift
//  VKApp
//
//  Created by 👩🏻‍🎨 📱 december11 on 08.03.2022.
//

import Foundation
import UIKit

extension UITableView {
    func sectionOf(row: Int) -> Int? {
        for section in 0..<self.numberOfSections {
            if row >= self.numberOfRows(inSection: section) {
                return section
            }
        }
        return nil
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let identifier = String(describing: T.self)
        guard
            let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T
        else { fatalError() }
        return cell
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
        let identifier = String(describing: T.self)
        guard
            let headerFooter = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T
        else { fatalError() }
        return headerFooter
    }
    
    func register<T: UITableViewHeaderFooterView>(for headerFooterView: T.Type) {
        let identifier = String(describing: T.self)
        register(UINib(nibName: identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func register<T: UITableViewCell>(for cell: T.Type) {
        let identifier = String(describing: T.self)
        register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
}
