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
}
