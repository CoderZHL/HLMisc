//
//  HLActivityIndicatorView.swift
//  OfficialAccounts
//
//  Created by 钟浩良 on 2018/3/20.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit

public protocol HLActivityIndicatorViewDelegate: class {
    func startAnimating(activityIndicatorView: HLActivityIndicatorView)
    func stopAnimating(activityIndicatorView: HLActivityIndicatorView)
}

public class HLActivityIndicatorView: UIView {
    public weak var delegate: HLActivityIndicatorViewDelegate?
    
    public var color: UIColor = UIColor.white
    
    public var isAnimating: Bool = false

    var percent: CGFloat = 1.0 {
        didSet {
            if self.isAnimating {
                if percent < 0.1 {
                    self.stopAnimationIfNeed()
                }
                return
            }
            
            if percent > 0.55 && self.isAutoStartAnimation {
                if !self.isAnimating {
                    self.startAnimating()
                }
            } else if Int(percent * CGFloat(segmentCount)) != Int(currentPrecent * CGFloat(segmentCount)) {
                self.setup(percent: percent, isAlphaOffset: self.isAlphaOffset)
            } else if currentPrecent == 0 && percent != 0 {
                self.setup(percent: percent, isAlphaOffset: self.isAlphaOffset)
            } else if currentPrecent != 0 && percent == 0 {
                self.setup(percent: 0, isAlphaOffset: self.isAlphaOffset)
            }
        }
    }
    
    var isAlphaOffset: Bool = false {
        didSet {
            if self.isAlphaOffset != oldValue {
                self.setup(percent: self.currentPrecent, isAlphaOffset: isAlphaOffset)
            }
        }
    }
    
    var isAutoStartAnimation: Bool = true
    
    private var _isStopAnimation: Bool = false {
        didSet {
            if _isStopAnimation {
                self.stopAnimationIfNeed()
            }
        }
    }
    
    private var currentPrecent: CGFloat = 0
    
    private var segmentCount = 12
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    func startAnimating() {
        if self.isAnimating { return }
        self.setup(percent: 1.0, isAlphaOffset: true)
        self.isAnimating = true
        self.setupAnimation()
        self.delegate?.startAnimating(activityIndicatorView: self)
        impactFeedback(style: .light)
    }
    
    func stopAnimating() {
        if !self._isStopAnimation {
            self._isStopAnimation = true
        }
    }
}

extension HLActivityIndicatorView {
    private func stopAnimationIfNeed() {
        guard isAnimating else {
            return
        }
        if self._isStopAnimation && self.percent < 0.1 {
            self._isStopAnimation = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.isAnimating = false
                self.setup(percent: 0.0, isAlphaOffset: false)
                self.layer.removeAllAnimations()
                self.delegate?.stopAnimating(activityIndicatorView: self)
            })
        }
    }
}

extension HLActivityIndicatorView {
    private func setup(percent: CGFloat, isAlphaOffset: Bool = false) {
        self.currentPrecent = percent
        self.isAlphaOffset = isAlphaOffset
        self.layer.sublayers?.forEach({ (layer) in
            layer.removeFromSuperlayer()
        })
        if percent <= 0 {
            return
        }
        
        let count = segmentCount
        let diameter = min(self.bounds.size.width, self.bounds.size.height)
        let scale: CGFloat = 25.0 / 100.0
        let height = diameter * scale
        let width = (diameter - height * 2) / 2 * tan(CGFloat.pi * 360.0 / CGFloat(count) / 180.0) - 2
        
        let angel = 360.0 / CGFloat(count)
        for i in 0 ..< count {
            if CGFloat(i) > CGFloat(count) * percent {
                break;
            }
            let layer = CALayer()
            layer.bounds = CGRect(x: 0, y: 0, width: width, height: height)
            layer.cornerRadius = width / 2
            layer.backgroundColor = self.color.cgColor
            if isAlphaOffset {
                layer.backgroundColor = self.color.cgColor.copy(alpha: 1 - CGFloat(count - i) * 0.07)
            } else {
                layer.backgroundColor = self.color.cgColor
            }
            let radion = angel * CGFloat(i) / 180.0 * CGFloat.pi
            layer.anchorPoint = CGPoint(x: 0.5, y: 1.0 / scale / 2.0)
            layer.position = CGPoint(x: diameter / 2, y: diameter / 2)
            layer.transform = CATransform3DMakeRotation(radion, 0, 0, 1)
            self.layer.addSublayer(layer)
        }
    }
    
    private func setupAnimation() {
        let animation = CABasicAnimation()
        animation.keyPath = "transform.rotation"
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.duration = 2.5
        self.layer.add(animation, forKey: nil)
    }
}

extension HLActivityIndicatorView {
    public func updatePercent(with viewOffset: CGFloat) {
        self.updatePercent(with: viewOffset, maxPercent: 1)
    }
    
    public func updatePercentNotStartAnimation(with viewOffset: CGFloat) {
        if self.percent <= 0 {
            let isHidden = viewOffset > 20
            if self.isHidden != isHidden {
                self.isHidden = isHidden
            }
            return
        }
        self.updatePercent(with: viewOffset, maxPercent: 0.5)
    }
    
    func updatePercent(with viewOffset: CGFloat, maxPercent: CGFloat) {
        let percent = min(max(-1 * (viewOffset + 20), 0) / 100, maxPercent)
        self.percent = percent
        
        let isHidden = viewOffset > 20
        if self.isHidden != isHidden {
            self.isHidden = isHidden
        }
    }
}
