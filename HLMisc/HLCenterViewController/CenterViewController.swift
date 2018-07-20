//
//  CenterViewController.swift
//  HupuHomePage
//
//  Created by 钟浩良 on 2018/5/16.
//  Copyright © 2018年 肇庆市华盈体育文化发展有限公司. All rights reserved.
//

import UIKit

public protocol CenterViewControllerDataSource: class {
    func instantiatePagingViews(_ viewController: CenterViewController) -> [UIView]
    func headerView(CenterViewController viewController: CenterViewController) -> HLPagingHeaderView
}

open class CenterViewController: UIViewController, CenterViewControllerDataSource, UIScrollViewDelegate {
    open weak var dataSource: CenterViewControllerDataSource!
    
    private weak var scrollView: UIScrollView!
    
    private weak var headerView: HLPagingHeaderView!
    
    private var headerTopLayoutConstraint: NSLayoutConstraint!
    
    private var pagingViews: [UIView] = []
    
    open func instantiatePagingViews(_ viewController: CenterViewController) -> [UIView] {
        let v = UIView()
        v.backgroundColor = .red
        let t = UITableView()
        t.backgroundColor = .green
        return [UITableView(), t, v]
    }
    
    open func headerView(CenterViewController viewController: CenterViewController) -> HLPagingHeaderView {
        return HLPagingHeaderView()
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.dataSource = self
    }
    
    required convenience public init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        self.dataSource = self
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = .init(rawValue: 0)
        self.setupScrollView()
        self.setupHeaderView()
        self.setupContentView()
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === self.scrollView else {
            return
        }
        let offsetX = scrollView.contentOffset.x
        let pageIndex = Int(offsetX / scrollView.bounds.size.width + 0.5)
        self.headerView.selectedIndex = pageIndex
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === self.scrollView || scrollView.window == nil { return }
        
        let offsetY = scrollView.contentOffset.y
        var originY: CGFloat = 0
        var otherOffsetY: CGFloat = 0
        let headerViewTravel = self.headerView.height - self.headerView.stuckHeight
        if offsetY <= headerViewTravel {
            originY = -offsetY
            if offsetY < 0 {
                otherOffsetY = 0
            } else {
                otherOffsetY = offsetY
            }
        } else {
            originY = -headerViewTravel
            otherOffsetY = headerViewTravel
        }
        
        self.headerTopLayoutConstraint.constant = originY
        self.pagingViews.enumerated().forEach { (index, view) in
            if index == self.headerView.selectedIndex { return }
            if !view.isKind(of: UIScrollView.self) { return }
            let tView = view as! UIScrollView
            let offset = CGPoint(x: 0, y: otherOffsetY)
            if tView.contentOffset.y < headerViewTravel || offset.y < headerViewTravel {
                tView.setContentOffset(offset, animated: false)
            }
        }
    }
}

extension CenterViewController {
    private func setupScrollView() {
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        self.view.addSubview(scrollView)
        self.scrollView = scrollView
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[s]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["s": scrollView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[s]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["s": scrollView]))
    }
    
    private func setupHeaderView() {
        let headerView = self.dataSource.headerView(CenterViewController: self)
        self.view.addSubview(headerView)
        self.headerView = headerView
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[h]-0-|", options: .init(rawValue: 0), metrics: nil, views: ["h": headerView]))
        self.headerTopLayoutConstraint = NSLayoutConstraint(item: headerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        self.view.addConstraint(self.headerTopLayoutConstraint)
        self.view.addConstraint(NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: headerView.height))
        
        headerView.didChangeSelectedIndexHanlder = { [unowned self] index in
            let view = self.pagingViews[index]
            self.scrollView.setContentOffset(CGPoint(x: view.frame.minX, y: 0), animated: true)
        }
    }
    
    private func setupContentView() {
        let headView = UIView()
        headView.frame = CGRect(x: 0, y: 0, width: 0, height: self.headerView.height)
        
        let views = self.dataSource.instantiatePagingViews(self)
        views.forEach { view in
            if view.isKind(of: UIScrollView.self) {
                (view as! UIScrollView).delegate = self
            }
            if view.isKind(of: UITableView.self) {
                (view as! UITableView).tableHeaderView = headView
            }
            view.translatesAutoresizingMaskIntoConstraints = false
            self.scrollView.addSubview(view)
            self.view.addConstraint(NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0))
            if let last = self.pagingViews.last {
                self.scrollView.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: last, attribute: .trailing, multiplier: 1, constant: 0))
                let cons = [NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: last, attribute: .top, multiplier: 1, constant: 0),
                            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: last, attribute: .bottom, multiplier: 1, constant: 0)]
                self.view.addConstraints(cons)
            } else {
                self.scrollView.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self.scrollView, attribute: .leading, multiplier: 1, constant: 0))
                let cons = [NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
                            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)]
                self.view.addConstraints(cons)
            }
            self.pagingViews.append(view)
        }
        
        self.scrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(self.pagingViews.count), height: 0)
    }
}
