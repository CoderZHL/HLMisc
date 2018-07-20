//
//  PopoverPresentationController.swift
//  Popover
//
//  Created by 钟浩良 on 2017/11/20.
//  Copyright © 2017年 钟浩良. All rights reserved.
//

import UIKit

class PopoverPresentationController: UIPresentationController {
    var presentFrame = CGRect.zero
    
    override func containerViewWillLayoutSubviews() {
        if presentFrame == .zero {
            presentedView?.frame = presentingViewController.view.frame
        } else {
            presentedView?.frame = presentFrame
        }
        
        containerView?.insertSubview(coverView, at: 0)
    }
    
    lazy var coverView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.2)
        view.frame = presentingViewController.view.frame
        
        let tap = UITapGestureRecognizer(target: self, action: Selector.tapHandler)
        view.addGestureRecognizer(tap)
        return view
    }()
    
    @objc func dismssPresentedView() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}


extension Selector {
    fileprivate static let tapHandler = #selector(PopoverPresentationController.dismssPresentedView)
}
