//
//  PushAnimation.swift
//  VKApp
//
//  Created by Alla Shkolnik on 29.01.2022.
//

import UIKit

final class PushAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    let animationTime = 0.6
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animationTime
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let destination = transitionContext.viewController(forKey: .to),
            let source = transitionContext.viewController(forKey: .from)
        else { return }
        

        destination.view.layer.anchorPoint = CGPoint(x: 1 , y: 0)
        destination.view.layer.transform = CATransform3DTranslate(
            CATransform3DIdentity,
            destination.view.bounds.width / 2,
            0,
            0)
        destination.view.layer.transform = CATransform3DRotate(destination.view.layer.transform, -.pi / 2, 0, 0, 1)
        destination.view.alpha = 0
        transitionContext.containerView.addSubview(destination.view)
        
        UIView.animate(withDuration: animationTime, delay: 0.0, options: .curveEaseInOut) {
            destination.view.alpha = 1
            destination.view.layer.transform = CATransform3DTranslate(
                CATransform3DIdentity,
                destination.view.bounds.width / 2,
                -destination.view.bounds.height / 2,
                0)
            source.view.setFrameX(-source.view.bounds.width)
        } completion: { isFinished in
            transitionContext.containerView.transform = .identity
            source.view.transform = .identity
            
            if (transitionContext.transitionWasCancelled) {
                destination.view.removeFromSuperview()
            } else {
                source.view.removeFromSuperview()
            }
            transitionContext.completeTransition(isFinished)
        }
        
    }
    
    
}
