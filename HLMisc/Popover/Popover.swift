//
//  Popover.swift
//  HLMisc
//
//  Created by 钟浩良 on 2018/7/27.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

public protocol PopoverTransitionDelegate: class {
    func transitionDuration(for popover: Popover, isPresent: Bool, using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    
    func popoverAnimator(_ popoverAnimator: Popover, isPresent: Bool, using transitionContext: UIViewControllerContextTransitioning)
}

public protocol PopoverDelegate: class {
    func presentationController(for popover: Popover, presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?
}

open class Popover: NSObject {
    public private(set) var isPresent = false
    
    public weak var delegate: PopoverDelegate!
    
    public weak var transitionDelegate: PopoverTransitionDelegate!
    
    private(set) weak var presentationController: UIPresentationController!
    
    public override init() {
        super.init()
        self.delegate = self
        self.transitionDelegate = self
    }
}

extension Popover: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresent = false
        return self
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let pc = self.delegate.presentationController(for: self, presented: presented, presenting: presenting, source: source)
        self.presentationController = pc
        return pc
    }
}

extension Popover: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDelegate.transitionDuration(for: self, isPresent: self.isPresent, using: transitionContext)
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionDelegate.popoverAnimator(self, isPresent: self.isPresent, using: transitionContext)
    }
}

extension Popover: PopoverDelegate {
    public func presentationController(for popover: Popover, presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension Popover: PopoverTransitionDelegate {
    public func transitionDuration(for popover: Popover, isPresent: Bool, using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.isPresent ? 0.25 : 0.1
    }
    
    public func popoverAnimator(_ popoverAnimator: Popover, isPresent: Bool, using transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            guard let toView = transitionContext.view(forKey: .to) else { return }
            toView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            transitionContext.containerView.addSubview(toView)
            transitionContext.containerView.alpha = 0
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut, animations: {
                toView.transform = CGAffineTransform.identity
                transitionContext.containerView.alpha = 1
            }) { (_) in
                transitionContext.completeTransition(true)
            }
        } else {
            let fromView = transitionContext.view(forKey: .from)
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, options: .curveEaseIn, animations: {
                fromView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                fromView?.alpha = 0.01
                transitionContext.containerView.subviews.filter({ $0 !== fromView }).forEach({ (view) in
                    view.alpha = 0.1
                })
            }, completion: { (_) in
                fromView?.alpha = 1
                transitionContext.completeTransition(true)
            })
        }
    }
}

fileprivate class PresentationController: UIPresentationController {
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        let size = self.presentedViewController.preferredContentSize
        let x = (self.presentingViewController.view.frame.width - size.width) / 2
        let y = (self.presentingViewController.view.frame.height - size.height) / 2
        presentedView?.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
        
        containerView?.insertSubview(coverView, at: 0)
    }
    
    lazy var coverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        view.frame = presentingViewController.view.frame
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapCoverView))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    @objc func onTapCoverView() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
