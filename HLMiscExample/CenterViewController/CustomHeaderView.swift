//
//  CustomHeaderView.swift
//  HupuHomePage
//
//  Created by 钟浩良 on 2018/5/16.
//  Copyright © 2018年 钟浩良. All rights reserved.
//

import UIKit
import HLMisc

class CustomHeaderView: HLPagingHeaderView {
    override var height: CGFloat {
        return 220
    }
    
    override var stuckHeight: CGFloat {
        return 44
    }
    
    override var selectedIndex: Int {
        set {
            self.segmentControl.selectedSegmentIndex = newValue
        }
        get {
            return self.segmentControl.selectedSegmentIndex
        }
    }
    
    weak var segmentControl: UISegmentedControl!
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view?.isKind(of: UIButton.self) ?? false || view?.isKind(of: UISegmentedControl.self) ?? false {
            return view
        }
        return nil
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.95, alpha: 1)
        self.setupUI()
        self.setupSegment()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let label = UILabel()
        label.text = "Demo Header View"
        self.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    private func setupSegment() {
        let seg = UISegmentedControl(items: ["动态", "文章", "更多"])
        self.segmentControl = seg
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["v": view]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[v(\(self.stuckHeight))]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["v": view]))
        
        view.addSubview(seg)
        seg.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: seg, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: seg, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        seg.selectedSegmentIndex = 0
        
        seg.addTarget(self, action: #selector(CustomHeaderView.segmentDidChangeValue(sender:)), for: .valueChanged)
    }
    
    @objc func segmentDidChangeValue(sender: UISegmentedControl) {
        self.didChangeSelectedIndexHanlder?(sender.selectedSegmentIndex)
    }
}
