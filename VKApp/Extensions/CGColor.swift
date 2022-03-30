//
//  CGColor.swift
//  VKApp
//
//  Created by 👩🏻‍🎨 📱 december11 on 09.03.2022.
//

import UIKit

extension CGColor {
    static func generateLightColor() -> CGColor {
        let color = CGColor(red: CGFloat.random(in: 155...255)/255,
                            green: CGFloat.random(in: 155...255)/255,
                            blue: CGFloat.random(in: 155...255)/255,
                            alpha: 1.0)
        return color
    }
}
