//
//  PopoverAnimator.swift
//  Popover
//
//  Created by 钟浩良 on 2017/11/20.
//  Copyright © 2017年 钟浩良. All rights reserved.
//

import UIKit

protocol PopoverAnimatorDelegate: class {
    func transitionDuration(for popoverAnimator: PopoverAnimator, isPresent: Bool, using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    
    func popoverAnimator(_ popoverAnimator: PopoverAnimator, isPresent: Bool, using transitionContext: UIViewControllerContextTransitioning)
}

class PopoverAnimator: NSObject {
    var isPresent: Bool = false
    
    var presentFrame = CGRect.zero
    
    weak var presentationController: PopoverPresentationController?
    
    weak var delegate: PopoverAnimatorDelegate!
}

extension PopoverAnimator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = false
        return self
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = PopoverPresentationController(presentedViewController: presented, presenting: presenting)
        pc.presentFrame = presentFrame
        self.presentationController = pc
        return pc
    }
}

extension PopoverAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return delegate.transitionDuration(for: self, isPresent: isPresent, using: transitionContext)
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        delegate.popoverAnimator(self, isPresent: isPresent, using: transitionContext)
    }

}
