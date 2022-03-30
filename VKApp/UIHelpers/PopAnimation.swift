//
//  PopAnimation.swift
//  VKApp
//
//  Created by Alla Shkolnik on 29.01.2022.
//

import UIKit

final class PopAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    let animationTime = 0.6
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animationTime
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let destination = transitionContext.viewController(forKey: .to),
            let source = transitionContext.viewController(forKey: .from)
        else { return }
        
        destination.view.layer.transform = CATransform3DTranslate(
            CATransform3DIdentity,
            -destination.view.bounds.width,
            0,
            0)
        source.view.alpha = 1
        transitionContext.containerView.addSubview(destination.view)
        
        
        UIView.animate(withDuration: animationTime, delay: 0.0, options: .curveEaseInOut) {
            source.view.alpha = 0
            source.view.layer.transform = CATransform3DMakeRotation(-.pi/2, 0, 0, 1)
            destination.view.setFrameX(0)
            source.view.setFrameX(source.view.bounds.width)
        } completion: { isFinished in
            if isFinished && !transitionContext.transitionWasCancelled {
                source.removeFromParent()
            } else if transitionContext.transitionWasCancelled {
                destination.view.transform = .identity
                
            }
            destination.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            transitionContext.completeTransition(isFinished)
        }
    }
}
