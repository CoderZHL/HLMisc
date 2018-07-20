//
//  BaseAnalysisView.swift
//  Football
//
//  Created by 钟浩良 on 2018/5/18.
//  Copyright © 2018年 bet007. All rights reserved.
//

import UIKit

open class EasyLayoutView: UIView {
    public func addView(_ view: UIView, topView: UIView?, topMargin: CGFloat = 0, leadingMargin: CGFloat = 0, trailingMargin: CGFloat = 0, height: CGFloat? = nil, in container: UIView?) {
        let container = container ?? self
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        
        if let top = topView {
            container.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: top, attribute: .bottom, multiplier: 1, constant: topMargin))
        } else {
            container.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1, constant: topMargin))
        }
        if let height = height {
            container.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
        }
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(leadingMargin)-[view]-\(trailingMargin)-|", options: .init(rawValue: 0), metrics: nil, views: ["view": view]))
    }
    
    public func addView(_ view: UIView, leadingView: UIView?, leadingMargin: CGFloat = 0, in container: UIView?) {
        let container = container ?? self
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint]
        if let leading = leadingView {
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[leading]-\(leadingMargin)-[view]", options: .init(rawValue: 0), metrics: nil, views: ["view": view, "leading": leading])
        } else {
            constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(leadingMargin)-[view]", options: .init(rawValue: 0), metrics: nil, views: ["view": view])
        }
        container.addConstraints(constraints)
        container.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["view": view]))
    }
    
    public func setupSubviewsLastTrainingConstraint(in superView: UIView, margin: CGFloat = 0) {
        if let last = superView.subviews.last {
            superView.addConstraint(NSLayoutConstraint(item: last, attribute: .trailing, relatedBy: .equal, toItem: superView, attribute: .trailing, multiplier: 1, constant: margin))
        }
    }
    
    public func setupSubviewsLastBottomConstraint(in superView: UIView, margin: CGFloat = 0) {
        if let last = superView.subviews.last {
            superView.addConstraint(NSLayoutConstraint(item: last, attribute: .bottom, relatedBy: .equal, toItem: superView, attribute: .bottom, multiplier: 1, constant: -margin))
        }
    }
}
