//
//  UIView+Nib.swift
//  VKApp
//
//  Created by Alla Shkolnik on 31.03.2022.
//

import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        let bundle = Bundle(for: T.self)
        guard
            let view = bundle.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as? T
        else { fatalError() }
        return view
    }
}
