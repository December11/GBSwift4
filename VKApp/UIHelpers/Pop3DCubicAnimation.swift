//
//  PopAnimation.swift
//  VKApp
//
//  Created by 👩🏻‍🎨 📱 december11 on 28.01.2022.
//

import UIKit

final class Pop3DCubicAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let animateTime = 1.0
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        animateTime
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let destination = transitionContext.viewController(forKey: .to),
            let source = transitionContext.viewController(forKey: .from)
        else { return }
        let const: CGFloat = -0.005
        
        destination.view.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
        source.view.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        var viewFromTransform: CATransform3D = CATransform3DMakeRotation(-.pi / 2, 0.0, 1.0, 0.0)
        var viewToTransform =  CATransform3DMakeRotation(.pi / 2, 0.0, 1.0, 0.0)
        viewFromTransform.m34 = const
        viewToTransform.m34 = const
        
        transitionContext.containerView.transform = CGAffineTransform(
            translationX: -transitionContext.containerView.frame.size.width / 2.0,
            y: 0)
        destination.view.layer.transform = viewToTransform
        transitionContext.containerView.addSubview(destination.view)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            transitionContext.containerView.transform = CGAffineTransform(
                translationX: transitionContext.containerView.frame.size.width / 2.0,
                y: 0)
            source.view.layer.transform = viewFromTransform
            destination.view.layer.transform = CATransform3DIdentity
        }, completion: {
            finished in
            transitionContext.containerView.transform = .identity
            source.view.layer.transform = CATransform3DIdentity
            destination.view.layer.transform = CATransform3DIdentity
            source.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            destination.view.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            if (transitionContext.transitionWasCancelled) {
                destination.view.removeFromSuperview()
            } else {
                source.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
