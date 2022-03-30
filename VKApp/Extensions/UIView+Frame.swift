// UIView+Frame.swift
// Copyright © Darkness Production. All rights reserved.

import UIKit

extension UIView {
    func setFrameX(_ value: CGFloat) {
        var frame = self.frame
        frame.origin.x = value
        self.frame = frame
    }

    func setFrameY(_ value: CGFloat) {
        var frame = self.frame
        frame.origin.y = value
        self.frame = frame
    }

    func setFrameWidth(_ value: CGFloat) {
        var frame = self.frame
        frame.size.width = value
        self.frame = frame
    }

    func setFrameHeight(_ value: CGFloat) {
        var frame = self.frame
        frame.size.height = value
        self.frame = frame
    }

    func setSize(_ size: CGSize) {
        var frame = self.frame
        frame.size = size
        self.frame = frame
    }

    func setWidth(_ value: CGFloat) {
        var frame = self.frame
        frame.size.width = value
        self.frame = frame
    }

    func setHeight(_ value: CGFloat) {
        var frame = self.frame
        frame.size.height = value
        self.frame = frame
    }
}
