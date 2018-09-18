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
    /// 颜色
    public var color: UIColor = UIColor.white
    /// 动画状态
    public var isAnimating: Bool = false
    /// 动画时长
    public var animationDuration: CFTimeInterval = 0.8
    /// 进度
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
    /// 条块图层的alpha是否渐变
    public var isAlphaOffset: Bool = false {
        didSet {
            if self.isAlphaOffset != oldValue {
                self.setup(percent: self.currentPrecent, isAlphaOffset: isAlphaOffset)
            }
        }
    }
    /// 是否自动开始动画
    public var isAutoStartAnimation: Bool = true
    /// 是否停止动画
    private var _isStopAnimation: Bool = false {
        didSet {
            if _isStopAnimation {
                self.stopAnimationIfNeed()
            }
        }
    }
    /// 当前进度
    private var currentPrecent: CGFloat = 0
    /// 条块数量
    private var segmentCount = 12
    /// 偏移值
    private var topInset: CGFloat = 0 {
        didSet {
            if topInset != oldValue {
                self.percent = self.calculatePercent(with: self.offsetCache)
            }
        }
    }
    /// offset的缓存
    private var offsetCache: CGFloat = 0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    /// 开始动画
    public func startAnimating() {
        if self.isAnimating { return }
        self.setup(percent: 1.0, isAlphaOffset: true)
        self.isAnimating = true
        self.setupAnimation()
        self.delegate?.startAnimating(activityIndicatorView: self)
        impactFeedback(style: .medium)
    }
    /// 停止动画
    public func stopAnimating(topInset: CGFloat = 0) {
        if !self._isStopAnimation && self.isAnimating {
            self.topInset = topInset
            self._isStopAnimation = true
        }
    }
}

extension HLActivityIndicatorView {
    private func stopAnimationIfNeed() {
        guard isAnimating else {
            self.topInset = 0
            return
        }
        if self._isStopAnimation {
            self.topInset = 0
            self._isStopAnimation = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.isAnimating = false
                self.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
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
        
        let parameter = self.circleParameter()
        let count = parameter.segmentCount
        let diameter = parameter.diameter
        let layerSize = parameter.lineLayerSize
        let scale = parameter.heightScale
        let height = layerSize.height
        let width = layerSize.width
        
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
        self.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        self.setUpAnimation(in: self.layer, size: self.bounds.size, color: self.color, segmentCount: self.segmentCount)
    }
}

extension HLActivityIndicatorView {
    private func circleParameter() -> (segmentCount: Int, diameter: CGFloat, lineLayerSize: CGSize, heightScale: CGFloat) {
        let count = self.segmentCount
        let diameter = min(self.bounds.size.width, self.bounds.size.height)
        let scale: CGFloat = 25.0 / 100.0
        let height = diameter * scale
        let width = (diameter - height * 2) / 2 * tan(CGFloat.pi * 360.0 / CGFloat(count) / 180.0) - 2
        return (segmentCount: count, diameter: diameter, lineLayerSize: CGSize(width: width, height: height), heightScale: scale)
    }
}

extension HLActivityIndicatorView {
    private func setUpAnimation(in layer: CALayer, size: CGSize, color: UIColor, segmentCount: Int) {
        let parameter = self.circleParameter()
        let lineSize = parameter.lineLayerSize
        let x = (layer.bounds.size.width - size.width) / 2
        let y = (layer.bounds.size.height - size.height) / 2
        let count = segmentCount
        let duration: CFTimeInterval = self.animationDuration
        let beginTime = CACurrentMediaTime()
        let interval: CFTimeInterval = 1 / CFTimeInterval(count)
        let beginTimes = (1...12).map { (index) -> CFTimeInterval in
            return CFTimeInterval(index) * interval
        }
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Animation
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        
        let valueInterval: CGFloat = 1 / max(CGFloat(segmentCount - 1), 1)
        let keyTimes = (0...count).map({ CGFloat($0) * valueInterval })
        animation.keyTimes = keyTimes as [NSNumber]
        animation.timingFunctions = [timingFunction, timingFunction]
        var values = keyTimes
        values[0] = 1
        animation.values = values
        animation.duration = duration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw lines
        for i in 0 ..< count {
            let line = lineAt(angle: CGFloat(Double.pi / Double(count) * 2 * Double(i)),
                              size: lineSize,
                              origin: CGPoint(x: x, y: y),
                              containerSize: size,
                              color: color)
            
            animation.beginTime = beginTime + beginTimes[i]
            line.add(animation, forKey: "animation")
            layer.addSublayer(line)
        }
    }
    
    private func lineAt(angle: CGFloat, size: CGSize, origin: CGPoint, containerSize: CGSize, color: UIColor) -> CALayer {
        let radius = containerSize.width / 2 - max(size.width, size.height) / 2
        let lineContainerSize = CGSize(width: max(size.width, size.height), height: max(size.width, size.height))
        let lineContainer = CALayer()
        let lineContainerFrame = CGRect(
            x: origin.x + radius * (cos(angle) + 1),
            y: origin.y + radius * (sin(angle) + 1),
            width: lineContainerSize.width,
            height: lineContainerSize.height)
        let line = self.layerWith(size: size, color: color)
        let lineFrame = CGRect(
            x: (lineContainerSize.width - size.width) / 2,
            y: (lineContainerSize.height - size.height) / 2,
            width: size.width,
            height: size.height)
        
        lineContainer.frame = lineContainerFrame
        line.frame = lineFrame
        lineContainer.addSublayer(line)
        lineContainer.sublayerTransform = CATransform3DMakeRotation(CGFloat(Double.pi / 2) + angle, 0, 0, 1)
        
        return lineContainer
    }
    
    private func layerWith(size: CGSize, color: UIColor) -> CALayer {
        let layer = CAShapeLayer()
        var path = UIBezierPath()
        path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: size.width, height: size.height), cornerRadius: size.width / 2)
        layer.fillColor = color.cgColor
        layer.backgroundColor = nil
        layer.path = path.cgPath
        layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return layer
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
        let percent = min(self.calculatePercent(with: viewOffset), maxPercent)
        self.percent = percent
        
        let isHidden = viewOffset > 20
        if self.isHidden != isHidden {
            self.isHidden = isHidden
        }
        self.offsetCache = viewOffset
    }
    
    private func calculatePercent(with viewOffset: CGFloat) -> CGFloat {
        let percent = min(max(-1 * (viewOffset + self.topInset + 20), 0) / 100, 1)
        return percent
    }
}
