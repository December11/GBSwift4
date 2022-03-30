//
//  CustomNavigationController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 28.01.2022.
//

import Foundation
import UIKit

final class CustomInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var isStarted = false
    var shouldFinish = false
}

final class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    private let interactiveTransition = CustomInteractiveTransition()
    private let pushAnimation = PushAnimation()
    private let popAnimation = PopAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        view.backgroundColor = .white
        
        let edgeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePan(_:)))
        edgeGestureRecognizer.edges = .left
        view.addGestureRecognizer(edgeGestureRecognizer)
    }
    
    @objc func edgePan(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            interactiveTransition.isStarted = true
            popViewController(animated: true)
        case .changed:
            guard let width = recognizer.view?.bounds.width
            else {
                interactiveTransition.isStarted = false
                interactiveTransition.cancel()
                return
            }
            
            let translation = recognizer.translation(in: view)
            let relativeTranslation = translation.x / width
            let progress = max (0, min(relativeTranslation, 1))
            interactiveTransition.update(progress)
            interactiveTransition.shouldFinish = progress > 0.35

        case .ended:
            interactiveTransition.isStarted = false
            interactiveTransition.shouldFinish ? interactiveTransition.finish() : interactiveTransition.cancel()
        case .failed,
                .cancelled:
            interactiveTransition.isStarted = false
            interactiveTransition.cancel()
            
        default:
            break
        }
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            switch operation {
            case .push:
                return pushAnimation
            case .pop:
                return popAnimation
            default:
                return nil
            }
        }
    
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning)
    -> UIViewControllerInteractiveTransitioning? {
        interactiveTransition.isStarted ? interactiveTransition : nil
    }
    
}
